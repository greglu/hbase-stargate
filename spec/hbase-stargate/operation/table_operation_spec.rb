require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Operation::TableOperation do
  before :all do
    url = ENV["STARGATE_URL"].nil? ? "http://localhost:8080" : ENV["STARGATE_URL"]
    @client = Stargate::Client.new(url)
    @table_name = "test-hbase-stargate"
  end

  it "should create a table called test-hbase-stargate" do
    @table_options = { :name => 'column_family1',
                       :max_version => 3,
                       :compression => Stargate::Model::CompressionType::NONE,
                       :in_memory => false,
                       :block_cache => false,
                       :ttl => -1,
                       :max_cell_size => 2147483647,
                       :bloomfilter => Stargate::Model::BloomType::NONE
                     }
    @client.create_table(@table_name, 'column_family1').should be_true
  end

  it "should show the table info of 'test-hbase-stargate'" do
    table = @client.show_table(@table_name)
    table.should.is_a? Stargate::Model::TableDescriptor
    table.name.should == "test-hbase-stargate"
    table.column_families.size.should == 1
    table.column_families.should respond_to(:each)
    table.column_families.map(&:name).should include("column_family1")
    table.column_families.each do |cf|
      cf.should be_a_kind_of Stargate::Model::ColumnDescriptor
      cf.max_versions.should == 3
      cf.bloomfilter.should == Stargate::Model::BloomType::NONE
      cf.compression.should == "NONE"
    end
  end

  it "should be able to add column families with #alter_table" do
    # Testing a basic alteration by adding a new column family
    @client.alter_table(@table_name, "column_family2").should be_true

    # Both column families should be present now
    table = @client.show_table(@table_name)
    table.column_families.size.should == 2
    table.column_families.map(&:name).should include("column_family1", "column_family2")

    table.column_families.each do |cf|
      cf.should be_a_kind_of Stargate::Model::ColumnDescriptor
      cf.max_versions.should == 3
      cf.bloomfilter.should == Stargate::Model::BloomType::NONE
      cf.compression.should == Stargate::Model::CompressionType::NONE
    end
  end

  it "should be able to alter the configuration of an existing column family" do
    # Create some rows so that we can check that they're still there after altering the table
    @client.set(@table_name, "row1", {"column_family1:cell1" => "row1-cf1-c1", "column_family2:cell1" => "row1-cf2-c1"}).should be_true
    @client.set(@table_name, "row2", {"column_family1:cell1" => "row2-cf1-c1", "column_family2:cell1" => "row2-cf2-c1"}).should be_true

    ["row1", "row2"].each do |row_id|
      row = @client.get(@table_name, row_id)
      row["column_family1:cell1"].value.should == "#{row_id}-cf1-c1"
      row["column_family2:cell1"].value.should == "#{row_id}-cf2-c1"
    end

    # Do the alteration and verify that they were modified
    @client.alter_table(@table_name, {:name => "column_family1", :max_versions => 1}, {:name => "column_family2", :bloomfilter => Stargate::Model::BloomType::ROW}).should be_true

    table = @client.show_table(@table_name)
    table.column_families.size.should == 2
    table.column_families.map(&:name).should include("column_family1", "column_family2")

    column_family1 = table.column_families.select{|cf| cf.name == "column_family1"}
    column_family1.size.should == 1
    column_family1 = column_family1.first
    column_family1.max_versions.should == 1

    column_family2 = table.column_families.select{|cf| cf.name == "column_family2"}
    column_family2.size.should == 1
    column_family2 = column_family2.first
    column_family2.bloomfilter.should == Stargate::Model::BloomType::ROW

    # Double check that the same rows and columns are still present
    ["row1", "row2"].each do |row_id|
      row = @client.get(@table_name, row_id)
      row["column_family1:cell1"].value.should == "#{row_id}-cf1-c1"
      row["column_family2:cell1"].value.should == "#{row_id}-cf2-c1"
    end
  end

  it "should delete the table 'test-hbase-stargate'" do
    lambda {
      table = @client.destroy_table(@table_name)
    }.should_not raise_error

    lambda {
      table = @client.show_table(@table_name)
    }.should raise_error(Stargate::TableNotFoundError)
  end

end
