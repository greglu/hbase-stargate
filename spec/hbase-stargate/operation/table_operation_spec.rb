require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Operation::TableOperation do
  before :all do
    url = ENV["STARGATE_URL"].nil? ? "http://localhost:8080" : ENV["STARGATE_URL"]
    @client = Stargate::Client.new(url)
  end

  it "should create a table called test-stargate-client" do
    table = @client.create_table('test-stargate-client', { :name => 'habbit',
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

  it "should show the table info of 'test-stargate-client'" do
    table = @client.show_table('test-stargate-client')
    table.should.is_a? Stargate::Model::TableDescriptor
    table.name.should == "test-stargate-client"
    table.column_families.should respond_to(:each)
    table.column_families.map(&:name).should include("habbit")
    table.column_families.each do |cf|
      cf.should.is_a? Stargate::Model::ColumnDescriptor
    end
  end

  it "should delete the table 'test-stargate-client'" do
    lambda {
      table = @client.destroy_table("test-stargate-client")
    }.should_not raise_error

    lambda {
      table = @client.show_table("test-stargate-client")
    }.should raise_error(Stargate::TableNotFoundError)
  end

  after :all do
  end
end
