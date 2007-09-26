require 'yaml'
require 'rubygems'
require 'active_support'

Inflector.inflections do |inflect|
  inflect.irregular 'foot', 'feet'
end

module Measurement
  VERSION = '1.0.0'
  @measurements = @prefixes = {}
  
  def self.measurements(name, parent=nil)
    filename = File.join(File.dirname(__FILE__), 'measurements', (parent || '.'), "#{name}.yml")
    puts filename
    if File.exist?(filename)
      @measurements[name] ||= YAML.load_file(filename)   
    end
  end
  
  def self.prefixes(prefix)
    @prefixes[prefix] ||= YAML.load_file(File.join(File.dirname(__FILE__), 'prefixes', "#{prefix}.yml"))
  end
  
  def self.create_class(module_name, class_name, superclass, &block)
    klass = Class.new superclass, &block
    module_name.constantize.const_set class_name, klass
  end
  
  def self.create_module(module_name, &block)
    mod = Module.new &block
    Measurement.const_set module_name, mod
  end
  
  # We'll lazy load each measurement module via cost_missing so we only load the ones we actually need.
  def self.const_missing(symbol)
    if measurements(symbol)
      load_measurement(symbol.to_s, measurements(symbol)['Base'])
    else
      super
    end
  end
  
  def self.define_class(unit, options, measurement_type)

    superclass = options['parent'] ? "Measurement::#{measurement_type}::#{options['parent']}" : "Measurement::#{measurement_type}::Base"
  
    klass = Measurement::create_class("Measurement::#{measurement_type}", unit, superclass.constantize )
    
    klass.send :to_base_multiplier=, options['to_base']
    if options['parent']
      klass.send :to_parent_multiplier=, options['to_parent'] ? options['to_parent'] : 1.0
    end
    klass.send :abbreviation=, options['abbreviation'] 
    klass.send :prefix=, options['prefix'] 
    
    # # Build prefixed classes
    if options['prefix']
      prefix = Measurement.prefixes(options['prefix']).each do |prefix, prefix_options|
        define_class("#{prefix.titleize}#{unit.downcase}", 
          options.merge(
            'abbreviation' => "#{prefix_options['abbreviation']}#{options['abbreviation']}", 
            'parent' => klass.to_s.demodulize,
            'to_parent' => "#{prefix_options['base']}**#{prefix_options['exponent']}",
            'prefix' => nil,
            'to_base' => nil
          ), measurement_type)
      end
    end
    
    klass # Return the class
  end

  def self.load_measurement(measurement_type, base_name)
  
    # Build the module
    mod = Measurement::create_module(measurement_type) do
      const_set 'BASE_UNIT', "Measurement::#{measurement_type}::#{base_name}"
    
      # We'll lazy load each measurement module via cost_missing so we only load the ones we actually need.
      def self.const_missing(symbol)
        puts "Name: #{self.name.demodulize}"
        if Measurement.measurements(symbol, self.name.demodulize)
          Measurement.load_measurement(symbol.to_s, Measurement.measurements(symbol, self.name.demodulize)['Base'])
        else
          super
        end
      end
    end

    # Build the Base Class
    Measurement.create_class "Measurement::#{measurement_type}", 'Base', Object do
      include Comparable
    
      attr_accessor :units
    
      def <=>(other)
        self.to_base.units <=> other.to_base.units
      end
    
      def initialize(units=0)
        @units = units
      end
  
      class << self
        attr_accessor :abbreviation, :to_base_multiplier, :to_parent_multiplier, :prefix
    
        def module_name
          self.to_s.sub("::#{self.to_s.demodulize}", '')
        end
    
        def base_unit
          "#{module_name}::BASE_UNIT".constantize.constantize
        end
      end

      def to_base
        if self.instance_of?(self.class.base_unit)
          self
        elsif self.class.to_base_multiplier
          self.class.base_unit.new(units * eval(self.class.to_base_multiplier.to_s))
        else
          to_parent.to_base
        end
      end
    
      def to_parent
        if self.class.to_parent_multiplier
          self.class.superclass.new(units * eval(self.class.to_parent_multiplier.to_s))
        else
          to_base
        end
      end
  
      def to_ancestor(ancestor)
        new_unit = self
        while !new_unit.instance_of?(ancestor)
          new_unit = new_unit.to_parent
        end
        new_unit
      end
  
      def to_child(child)
        child.new(units / child.new(1).to_ancestor(self.class).units)
      end
    
      def method_missing(method_name, *args)
        if method_name.to_s =~ /^to_/ && defined?("#{self.class.module_name}::#{method_name.to_s[3..-1].singularize.classify}".constantize)
          klass = "#{self.class.module_name}::#{method_name.to_s[3..-1].singularize.classify}".constantize
          if self.class.ancestors.include?(klass)
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
  
    # Load all the measurements
    yaml = Measurement.measurements(measurement_type)
    yaml.delete('Base')
    while !yaml.empty?
      yaml.each do |unit, options|
        # if the parent has been defined, we're good
        if options['parent'].nil? || !yaml.has_key?(options['parent'])
          define_class(unit, options, measurement_type)
          yaml.delete(unit)
        end
      end
    end

    mod
  end
end