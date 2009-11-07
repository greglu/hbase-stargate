require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Operation::ScannerOperation do
  before :all do
    url = ENV["HBASE_URL"].nil? ? "http://localhost:60050" : ENV["HBASE_URL"]
    @client = HBase::Client.new(url)

    table = @client.create_table("test-hbase-ruby", "col1")
    @client.create_row('test-hbase-ruby', 'row1', {:name => 'col1:', :value => "row1-col1"})
    @client.create_row('test-hbase-ruby', 'row2', {:name => 'col1:', :value => "row2-col1"})
    @client.create_row('test-hbase-ruby', 'row3', {:name => 'col1:', :value => "row3-col1"})
  end

  it "should obtain a scanner" do
    # The test will pass but will make table_disable fail. Seems the problem of server side

#     scanner = @client.open_scanner("test-hbase-ruby", 'col1:')
#     scanner.should.is_a? HBase::Model::Scanner
#     scanner.scanner_id.should.is_a? Integer

#     lambda {
#       @client.close_scanner(scanner)
#     }.should_not raise_error
  end

  after :all do
    @client.destroy_table("test-hbase-ruby")
  end
end
