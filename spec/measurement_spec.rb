require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveSupport::Inflector do
  it "should pluralize 'foot' to 'feet'" do
    ActiveSupport::Inflector.pluralize('foot').should == 'feet'
  end
  it "should singularize 'feet' to 'foot'" do
    ActiveSupport::Inflector.pluralize('foot').should == 'feet'
  end
end