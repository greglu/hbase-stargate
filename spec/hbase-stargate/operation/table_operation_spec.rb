require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Operation::TableOperation do
  before :all do
    url = ENV["STARGATE_URL"].nil? ? "http://localhost:8080" : ENV["STARGATE_URL"]
    @client = Stargate::Client.new(url)
  end

  it "should create a table called test-hbase-stargate" do
    table = @client.create_table('test-hbase-stargate', { :name => 'habbit',
                                   :max_version => 3,
                                   :compression => Stargate::Model::CompressionType::NONE,
                                   :in_memory => false,
                                   :block_cache => false,
                                   :ttl => -1,
                                   :max_cell_size => 2147483647,
                                   :bloomfilter => false
                                 })
    table.should.is_a? Stargate::Model::TableDescriptor
  end

  it "should show the table info of 'test-hbase-stargate'" do
    table = @client.show_table('test-hbase-stargate')
    table.should.is_a? Stargate::Model::TableDescriptor
    table.name.should == "test-hbase-stargate"
    table.column_families.should respond_to(:each)
    table.column_families.map(&:name).should include("habbit")
    table.column_families.each do |cf|
      cf.should.is_a? Stargate::Model::ColumnDescriptor
    end
  end

  it "should delete the table 'test-hbase-stargate'" do
    lambda {
      table = @client.destroy_table("test-hbase-stargate")
    }.should_not raise_error

    lambda {
      table = @client.show_table("test-hbase-stargate")
    }.should raise_error(Stargate::TableNotFoundError)
  end

end
