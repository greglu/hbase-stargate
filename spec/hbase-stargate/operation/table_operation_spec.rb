require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Operation::TableOperation do

  before(:all) do
    url = ENV["STARGATE_URL"].nil? ? "http://localhost:8080" : ENV["STARGATE_URL"]
    @client = Stargate::Client.new(url)
    @table_options = { :name => 'col1',
                       :versions => 3,
                       :compression => Stargate::Model::CompressionType::NONE,
                       :in_memory => false,
                       :block_cache => false,
                       :ttl => -1,
                       :length => 2147483647,
                       :bloomfilter => false
                     }
  end

  it "should create a table called test-hbase-stargate" do
    @client.table_exists?("test-hbase-stargate").should be_false
    table = @client.create_table('test-hbase-stargate', @table_options, "col2")
    table.should be_a_kind_of Stargate::Model::TableDescriptor
    @client.table_exists?("test-hbase-stargate").should be_true
  end

  it "should not recreate a table" do
  end

  it "should reject invalid arguments passed to create" do
    lambda {
      @client.create_table('test-hbase-stargate2', { :invalid => "value" })
    }.should raise_error(ArgumentError)
  end

  it "should show the table info of 'test-hbase-stargate'" do
    table = @client.show_table('test-hbase-stargate')
    table.should.is_a? Stargate::Model::TableDescriptor
    table.name.should == "test-hbase-stargate"
    table.column_families.should respond_to(:each)
    table.column_families.map(&:name).should include("col1")
    table.column_families.each do |cf|
      cf.should be_a_kind_of Stargate::Model::ColumnDescriptor
    end
  end

  it "should give a list of regions" do
    regions = @client.table_regions('test-hbase-stargate')
    regions.should be_a_kind_of Array
    regions.each do |region|
      region.should be_a_kind_of Stargate::Model::Region
    end

    lambda {
      @client.table_regions('non-existant-table')
    }.should raise_error(Stargate::TableNotFoundError)
  end

  it "should delete the table 'test-hbase-stargate'" do
    lambda {
      destroyed = @client.delete_table("test-hbase-stargate")
      destroyed.should be_true
      @client.table_exists?("test-hbase-stargate").should be_false
    }.should_not raise_error

    lambda {
      @client.delete_table("test-hbase-stargate").should be_false
    }.should_not raise_error

    lambda {
      table = @client.show_table("test-hbase-stargate")
    }.should raise_error(Stargate::TableNotFoundError)
  end

end
