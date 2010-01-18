require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Model::Row do

  it "should be have such attributes" do
    obj = Stargate::Model::Row.new({})
    %w{name table_name columns}.each do |method|
      obj.should respond_to(method)
    end
  end

end
