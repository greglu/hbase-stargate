require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Model::CompressionType do

  it "should be return the correct type" do
    Stargate::Model::CompressionType.to_compression_type("RECORD").should == "RECORD"
    Stargate::Model::CompressionType.to_compression_type("BLOCK").should == "BLOCK"
    Stargate::Model::CompressionType.to_compression_type("NONE").should == "NONE"
    Stargate::Model::CompressionType.to_compression_type("OTHER").should == "NONE"
  end

end

describe Stargate::Model::ColumnDescriptor do

  it "should be have such attributes" do
    column = Stargate::Model::ColumnDescriptor.new({})
    %w{name compression bloomfilter maximum_cell_size max_versions}.each do |method|
      column.should respond_to(method)
    end
  end

end
