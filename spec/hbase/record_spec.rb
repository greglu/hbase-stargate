require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe HBase::Model::Record do

  # Stub
  it "should be true" do
    true.should == true
  end

  describe "Init" do

    it "should be successfuly when has the such instance variable" do
      class HBase::Model::Record ; attr_accessor :a ; end
      record = HBase::Model::Record.new({:a => 1})
      record.a.should == 1
    end

    it "should be not set the attribute when no such instance variable" do
      record = HBase::Model::Record.new({:a => 1})
      lambda{record.sent(:a)}.should raise_error NoMethodError
    end

  end

end
