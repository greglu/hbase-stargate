require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Operation::MetaOperation do

  before do
    url = ENV["HBASE_URL"].nil? ? "http://localhost:60050/" : ENV["HBASE_URL"]
    @client = HBase::Client.new(url)
  end

  it "should return tables" do
    tables = @client.list_tables
    tables.should respond_to(:size)
    tables.each do |table|
      table.should.is_a? HBase::Model::TableDescriptor
    end
  end

end
