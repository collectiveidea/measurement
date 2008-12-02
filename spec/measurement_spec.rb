require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Measurement do
  it "should lazily load constants" do
    defined?(Measurement::Length).should be_nil
    Measurement::Length
    defined?(Measurement::Length).should == 'constant'
  end
  
  describe "temperature" do
    it "should convert -459.67 F to 0 K" do
      pending
      Measurement::Temperature::Farenheit.new(-459.67).to_kelvin.should == Measurement::Temperature::Kelvin.new(0)
    end
    
    it "should convert 0 K to -459.67 F" do
      pending
      Measurement::Temperature::Kelvin.new(0).to_farenheit.should == Measurement::Temperature::Farenheit.new(-459.67)
    end
    
    it "should convert 32 F to 0 C" do
      pending
      Measurement::Temperature::Farenheit.new(32).to_celsius.should == Measurement::Temperature::Celsius.new(0)
    end

    it "should convert 212 F to 100 C" do
      pending
      Measurement::Temperature::Farenheit.new(212).to_celsius.should == Measurement::Temperature::Celsius.new(100)
    end

    it "should convert 0 C to 32 F" do
      pending
      Measurement::Temperature::Celsius.new(0).to_farenheit.should == Measurement::Temperature::Farenheit.new(32)
    end

    it "should convert 100 C to 212 F" do
      pending
      Measurement::Temperature::Celsius.new(100).to_farenheit.should == Measurement::Temperature::Farenheit.new(212)
    end
  end
end