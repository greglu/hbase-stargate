require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Model::TableDescriptor do

  it "should be have such attributes" do
    obj = Stargate::Model::TableDescriptor.new({})
    %w{name column_families}.each do |method|
      obj.should respond_to(method)
    end
  end

end
