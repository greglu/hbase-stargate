require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Model::Column do

  it "should be have such attributes" do
    column = Stargate::Model::Column.new({})
    %w{name value timestamp}.each do |method|
      column.should respond_to(method)
    end
  end

end
