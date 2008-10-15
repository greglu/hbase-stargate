require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Model::Row do

  it "should be have such attributes" do
    obj = HBase::Model::Row.new({})
    %w{name table_name timestamp columns}.each do |method|
      obj.should respond_to(method)
    end
  end

end
