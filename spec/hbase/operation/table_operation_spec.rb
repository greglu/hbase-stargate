require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Operation::TableOperation do
  before :all do
    url = ENV["HBASE_URL"].nil? ? "http://localhost:60050/" : ENV["HBASE_URL"]
    @client = HBase::Client.new(url)
  end

  it "should create a table called test-hbase-ruby" do
    table = @client.create_table('test-hbase-ruby', { :name => 'habbit',
                                   :max_version => 3,
                                   :compression => HBase::Model::CompressionType::NONE,
                                   :in_memory => false,
                                   :block_cache => false,
                                   :ttl => -1,
                                   :max_cell_size => 2147483647,
                                   :bloomfilter => false
                                 })
    table.should.is_a? HBase::Model::TableDescriptor
  end

  it "should show the table info of 'test-hbase-ruby'" do
    table = @client.show_table('test-hbase-ruby')
    table.should.is_a? HBase::Model::TableDescriptor
    table.name.should == "test-hbase-ruby"
    table.column_families.should respond_to(:each)
    table.column_families.each do |cf|
      cf.should.is_a? HBase::Model::ColumnDescriptor
    end
  end

  it "should disable table 'test-hbase-ruby'" do
    lambda {
      table = @client.disable_table('test-hbase-ruby')
    }.should_not raise_error
  end

  it "should enable table 'test-hbase-ruby'" do
    lambda {
      table = @client.enable_table('test-hbase-ruby')
    }.should_not raise_error
  end

  it "should delete the table 'test-hbase-ruby'" do
    lambda {
      table = @client.destroy_table("test-hbase-ruby")
    }.should_not raise_error

    lambda {
      table = @client.show_table("test-hbase-ruby")
    }.should raise_error(HBase::TableNotFoundError)
  end

  after :all do
  end
end
