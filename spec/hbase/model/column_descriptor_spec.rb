require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Model::CompressionType do

  it "should be return the correct type" do
    HBase::Model::CompressionType.to_compression_type("RECORD").should == "RECORD"
    HBase::Model::CompressionType.to_compression_type("BLOCK").should == "BLOCK"
    HBase::Model::CompressionType.to_compression_type("NONE").should == "NONE"
    HBase::Model::CompressionType.to_compression_type("OTHER").should == "NONE"
  end

end
