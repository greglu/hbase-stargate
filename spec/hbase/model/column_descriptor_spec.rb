require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Model::CompressionType do

  it "should be return the correct type" do
    HBase::Model::CompressionType.to_compression_type("RECORD").should == "RECORD"
    HBase::Model::CompressionType.to_compression_type("BLOCK").should == "BLOCK"
    HBase::Model::CompressionType.to_compression_type("NONE").should == "NONE"
    HBase::Model::CompressionType.to_compression_type("OTHER").should == "NONE"
  end

end

describe HBase::Model::ColumnDescriptor do

  it "should be have such attributes" do
    column = HBase::Model::ColumnDescriptor.new({})
    %w{name compression bloomfilter maximum_cell_size max_versions}.each do |method|
      column.should respond_to(method)
    end
  end

end
