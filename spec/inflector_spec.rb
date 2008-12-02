require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveSupport::Inflector do
  it "should pluralize 'foot' to 'feet'" do
    'foot'.pluralize.should == 'feet'
  end
  it "should singularize 'feet' to 'foot'" do
    'feet'.singularize.should == 'foot'
  end
  
  it "should not pluralize 'celsius'" do
    'celsius'.pluralize.should == 'celsius'
  end
  it "should not singularize 'celcius'" do
    'celsius'.singularize.should == 'celsius'
  end
end

