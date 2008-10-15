require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Model::Column do

  it "should be have such attributes" do
    column = HBase::Model::Column.new({})
    %w{name value timestamp}.each do |method|
      column.should respond_to(method)
    end
  end

end
