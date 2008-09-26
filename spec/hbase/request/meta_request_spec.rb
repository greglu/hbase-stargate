require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Request::MetaRequest do

  it "should get create_table path correctly" do
    mr = HBase::Request::MetaRequest.new
    mr.create_table.should == "/tables"
  end

end
