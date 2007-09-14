require 'yaml'
require 'rubygems'
require 'active_support' # for String#constantize

Inflector.inflections do |inflect|
  inflect.irregular 'foot', 'feet'
end

module Measurement
  module Length
    BASE_UNIT = 'Meter'
    
    class Base
      
      attr_accessor :units
      
      def initialize(units=0)
        @units = units
      end
      
      def to_parent
        BASE_UNIT.constantize.new(units)
      end
      
      def to_base
        BASE_UNIT.constantize.new(units)
      end
    end
    
    def self.create_class(class_name, superclass, &block)
      klass = Class.new superclass, &block
      Object.const_set class_name, klass
    end
    
    yaml = YAML.load_file(File.join(File.dirname(__FILE__), 'length.yml'))
    array = yaml.to_a
    sorted_array = array.select{|a| a[1]['parent'].nil?}
    array.delete_if{|a| a[1]['parent'].nil?}
    while !array.empty?
      array.each do |a|
        if sorted_array.map{|s|s[0]}.include?(a[1]['parent'])
          sorted_array << a 
          array.delete(a)
        end
      end
    end
    
    sorted_array.each do |unit, options|

      superclass = options['parent'] ? options['parent'].constantize : Base

      self.create_class(unit, superclass ) do
        class << self
          attr_accessor :to_base_multiplier, :to_parent_multiplier
        end        
  
        def mult
          self.class.to_parent_multiplier
        end
  
        def to_base
          if self.class == BASE_UNIT.constantize
            super
          elsif self.class.to_base_multiplier
            BASE_UNIT.constantize.new(units * eval(self.class.to_base_multiplier.to_s))
          else
            to_parent.to_base
          end
        end
  
        def to_parent
          if self.class == BASE_UNIT
            super
          elsif self.class.to_parent_multiplier
            self.class.superclass.new units * eval(self.class.to_parent_multiplier.to_s)
          else
            self.class.superclass.new to_base
          end
        end
        
        def to_ancestor(ancestor)
          new_unit = self
          while new_unit.class != ancestor
            new_unit = new_unit.to_parent
          end
          new_unit
        end
        
        def to_child(child)
          units / child.new(1).to_ancestor(self.class).units
        end
        
        def method_missing(method_name, *args)
          if method_name.to_s =~ /^to_/ && defined?(method_name.to_s[3..-1].singularize.classify.constantize)
            klass = method_name.to_s[3..-1].singularize.classify.constantize
            
            if klass == BASE_UNIT.constantize || self.class.ancestors.include?(klass)
              # is a parent
              to_ancestor(klass)
            elsif klass.ancestors.include?(self.class)
              # is a child
              to_child(klass)
            else
              # Have to go through the base unit
              to_base.to_child(klass)
            end
          else
            super(method_name, *args)
          end
        end
            
      end
        
      unit.constantize.send :to_base_multiplier=, options['to_base']
      unit.constantize.send :to_parent_multiplier=, options['to_parent']      
      
    end
  end
end