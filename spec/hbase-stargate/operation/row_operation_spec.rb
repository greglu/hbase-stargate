require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Operation::RowOperation do
  before :all do
    url = ENV["STARGATE_URL"].nil? ? "http://localhost:8080" : ENV["STARGATE_URL"]

    @client = Stargate::Client.new(url)

    table = @client.create_table("test-hbase-stargate", "col1")
  end

  it "should raise errors when the table doesn't exist" do
    lambda {
      @client.show_row("non-existant-table", "non-existant-row")
    }.should raise_error(Stargate::TableNotFoundError)

    lambda {
      @client.create_row("non-existant-table", "non-existant-row", nil, {:name => "col1:", :value => "row1-col1"})
    }.should raise_error(Stargate::TableNotFoundError)

    lambda {
      @client.delete_row("non-existant-table", "non-existant-row")
    }.should raise_error(Stargate::TableNotFoundError)
  end

  it "should create a row called 'row1'" do
    lambda {
      @client.create_row("test-hbase-stargate", "row1", nil, { :name => "col1:", :value => "row1-col1" }).should be_true
    }.should_not raise_error

    lambda {
      @client.show_row("test-hbase-stargate", "row1")["col1:"].value.should == "row1-col1"
    }.should_not raise_error

    lambda {
      row = @client.show_row("test-hbase-stargate", "nonexistant-row")
    }.should raise_error(Stargate::RowNotFoundError)
  end

  it "should create a row named 'row2' with timestamp value" do
    timestamp = (Time.now - (5*60)).to_i
    lambda {
      @client.create_row("test-hbase-stargate", "row2", timestamp, [{ :name => "col1:cell1", :value => "row2-col1-cell1" }, { :name => "col1:cell2", :value => "row2-col1-cell2" }]).should be_true
    }.should_not raise_error

    row = @client.show_row("test-hbase-stargate", "row2")
    row.should be_a_kind_of(Stargate::Model::Row)
    row.name.should == "row2"

    # Checking the columns using the old Array method
    columns = row.columns
    columns.size.should == 2
    columns[0].name.should == "col1:cell1"
    columns[0].value.should == "row2-col1-cell1"
    columns[0].timestamp.should == timestamp
    columns[1].name.should == "col1:cell2"
    columns[1].value.should == "row2-col1-cell2"
    columns[1].timestamp.should == timestamp

    # Checking the columns using the hashmap method
    row["col1:cell1"].should be_a_kind_of(Stargate::Model::Column)
    row["col1:cell1"].value.should == "row2-col1-cell1"
    row["col1:cell1"].timestamp.should == timestamp
    row["col1:cell2"].should be_a_kind_of(Stargate::Model::Column)
    row["col1:cell2"].value.should == "row2-col1-cell2"
    row["col1:cell2"].timestamp.should == timestamp
  end

  it "should show the rows 'row1'" do
    row = @client.show_row("test-hbase-stargate", "row1")
    row.should.is_a? Stargate::Model::Row
    row.table_name.should == "test-hbase-stargate"
    row.name.should == "row1"
    row.columns.size.should == 1
    row.columns.each do |col|
      col.should.is_a? Stargate::Model::Column
      col.name.should == "col1:"
      col.value.should == "row1-col1"
    end
  end

  it "should support globbing of the row key by showing rows 'row', 'row1' and 'row2' but not 'pow1'" do
    lambda {
      @client.create_row("test-hbase-stargate", "pow1", nil, { :name => "col1:", :value => "pow1-col1" }).should be_true
      @client.create_row("test-hbase-stargate", "row", nil, { :name => "col1:", :value => "row-col1" }).should be_true
    }.should_not raise_error
    rows = @client.show_row("test-hbase-stargate", "row*")
    rows.size.should == 3
    rows.each do |row|
      row.should.is_a? Stargate::Model::Row
      row.table_name.should == "test-hbase-stargate"
      row.columns.each do |col|
        col.should.is_a? Stargate::Model::Column
      end
    end
  end

  it "should delete rows when timestamps are defined" do
    row1 = @client.show_row("test-hbase-stargate", "row1")
    timestamp = row1.columns.map(&:timestamp).uniq.first

    lambda {
      @client.delete_row('test-hbase-stargate', 'row1', timestamp).should be_true
    }.should_not raise_error

    lambda {
      @client.show_row('test-hbase-stargate', 'row1')
    }.should raise_error
  end

  it "should delete rows without a timestamp provided" do
    row2 = @client.show_row("test-hbase-stargate", "row2")

    lambda {
      @client.delete_row('test-hbase-stargate', 'row2').should be_true
    }.should_not raise_error

    lambda {
      @client.show_row('test-hbase-stargate', 'row2')
    }.should raise_error
  end

  after :all do
    table = @client.destroy_table("test-hbase-stargate")
  end
end
