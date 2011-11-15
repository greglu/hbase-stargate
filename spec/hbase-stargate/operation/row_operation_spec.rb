require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Operation::RowOperation do

  before :all do
    url = ENV["STARGATE_URL"].nil? ? "http://localhost:8080" : ENV["STARGATE_URL"]

    @client = Stargate::Client.new(url)
    @table_name = "test-hbase-stargate"

    table = @client.create_table(@table_name, "col1")
  end

  after :all do
    table = @client.destroy_table(@table_name)
  end

  before :each do
    # Clear the table of any current records
    scanner = @client.open_scanner("test-hbase-stargate")
    begin
      @client.each_row(scanner) do |row|
        @client.delete_row(@table_name, row.name)
      end
    ensure
      @client.close_scanner(scanner)
    end
  end

  it "should raise errors when the table or row doesn't exist" do
    lambda {
      @client.set("non-existant-table", "nonexistant-row", {"col1" => "row1-col1"})
    }.should raise_error(Stargate::TableNotFoundError)

    lambda {
      @client.delete_row("non-existant-table", "non-existant-row")
    }.should raise_error(Stargate::TableNotFoundError)

    lambda {
      @client.show_row("non-existant-table", "non-existant-row")
    }.should raise_error(Stargate::TableNotFoundError)

    lambda {
      @client.create_row("non-existant-table", "non-existant-row", nil, {:name => "col1:", :value => "row1-col1"})
    }.should raise_error(Stargate::TableNotFoundError)

    lambda {
      @client.show_row(@table_name, "nonexistant-row")
    }.should raise_error(Stargate::RowNotFoundError)
  end

  it "should create and read a row called 'row1'" do
    # New API
    @client.set(@table_name, "row1", {"col1:cell1" => "row1-col1"}).should be_true
    @client.show_row(@table_name, "row1")["col1:cell1"].value.should == "row1-col1"
    # @client.get(@table_name, "row1")["col1:cell1"].value.should == "row1-col1"

    # Old API
    @client.create_row(@table_name, "row2", nil, {:name => "col1:cell1", :value => "row2-col1"}).should be_true
    @client.show_row(@table_name, "row2")["col1:cell1"].value.should == "row2-col1"
  end

  it "should be able to store multiple columns and use timestamps" do
    # timestamp = (Time.now - (5*60)).to_i

    @client.set(@table_name, "new-set-row1", {"col1:cell1" => "col1-cell1-value", "col1:cell2" => "col1-cell2-value" }).should be_true

    @client.set(@table_name, "new-set-row2", {"col1:cell1" => "col1-cell1-value", "col1:cell2" => "col1-cell2-value" }).should be_true

    row1 = @client.show_row(@table_name, "new-set-row1")
    row2 = @client.show_row(@table_name, "new-set-row2")

    [row1, row2].each do |row|
      row["col1:cell1"].value.should == "col1-cell1-value"
      row["col1:cell2"].value.should == "col1-cell2-value"
    end

    # row2["col1:cell1"].timestamp.should == timestamp
    # row2["col1:cell2"].timestamp.should == timestamp
  end

  it "should be able to get versions" do
    # Save 5 different versions
    @client.set(@table_name, "row1", {"col1:cell1" => "col1-cell1-value-version1" }).should be_true
    @client.set(@table_name, "row1", {"col1:cell1" => "col1-cell1-value-version2" }).should be_true
    @client.set(@table_name, "row1", {"col1:cell1" => "col1-cell1-value-version3" }).should be_true
    @client.set(@table_name, "row1", {"col1:cell1" => "col1-cell1-value-version4" }).should be_true
    @client.set(@table_name, "row1", {"col1:cell1" => "col1-cell1-value-version5" }).should be_true

    # Retrieving only 2 versions out of the maximum of 3 stored, and making sure they're returned in the right order
    row1 = @client.show_row(@table_name, "row1", nil, nil, :version => 2)
    row1.name.should == "row1"
    row1.columns.size.should == 1
    column = row1.columns.first
    column.name.should == "col1:cell1"
    column.value.should == "col1-cell1-value-version5"
    column.versions.size.should == 1
    column.versions[0].value.should == "col1-cell1-value-version4"

    row1 = @client.show_row(@table_name, "row1", nil, nil, :version => 3)
    row1.name.should == "row1"
    row1.columns.size.should == 1
    column = row1.columns.first
    column.name.should == "col1:cell1"
    column.value.should == "col1-cell1-value-version5"
    column.versions.size.should == 2
    column.versions[0].value.should == "col1-cell1-value-version4"
    column.versions[1].value.should == "col1-cell1-value-version3"
  end

  it "should create a row named 'row2' with timestamp value" do
    # TODO: Figure out why the hell this sleep is needed for the test to pass
    sleep 1

    timestamp = Time.now.to_i*1000
    @client.create_row(@table_name, "row2", timestamp, [{ :name => "col1:cell1", :value => "row2-col1-cell1" }, { :name => "col1:cell2", :value => "row2-col1-cell2" }]).should be_true

    row = @client.show_row(@table_name, "row2")
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

  it "should support globbing of the row key by showing rows 'row', 'row1' and 'row2' but not 'pow1'" do
    @client.create_row(@table_name, "pow1", nil, { :name => "col1:", :value => "pow1-col1" }).should be_true
    @client.create_row(@table_name, "row1", nil, { :name => "col1:", :value => "row-col1" }).should be_true
    @client.create_row(@table_name, "row2", nil, { :name => "col1:", :value => "row-col1" }).should be_true
    @client.create_row(@table_name, "row3", nil, { :name => "col1:", :value => "row-col1" }).should be_true

    rows = @client.show_row(@table_name, "row*")
    rows.size.should == 3
    (rows.map(&:name) - ["row1", "row2", "row3"]).should be_empty

    rows.each do |row|
      row.should be_a_kind_of(Stargate::Model::Row)
      row.table_name.should == @table_name
      row.columns.size.should == 1
      row["col1:"].should be_a_kind_of(Stargate::Model::Column)
      row["col1:"].value.should == "row-col1"
    end
  end

  it "should delete rows when timestamps are defined" do
    @client.set(@table_name, "row1", {"col1:cell1" => "col1-cell1-version1", "col1:cell2" => "col1-cell2-version1" }).should be_true
    sleep 1
    @client.set(@table_name, "row1", {"col1:cell1" => "col1-cell1-version2", "col1:cell2" => "col1-cell2-version2" }).should be_true
    
    row1 = @client.show_row(@table_name, "row1", nil, nil, :version => 3)

    row1["col1:cell1"].value.should == "col1-cell1-version2"
    row1["col1:cell1"].versions.size.should == 1

    newer_timestamp = row1["col1:cell1"].timestamp
    older_timestamp = row1["col1:cell1"].versions.first.timestamp

    lambda {
      @client.delete_row(@table_name, 'row1', older_timestamp).should be_true
    }.should_not raise_error

    row1 = @client.show_row(@table_name, "row1", nil, nil, :version => 3)
    row1["col1:cell1"].timestamp.should == newer_timestamp
    
    lambda {
      @client.delete_row(@table_name, 'row1', newer_timestamp).should be_true
    }.should_not raise_error

    lambda {
      @client.show_row(@table_name, 'row1')
    }.should raise_error(Stargate::RowNotFoundError)
  end

  it "should delete rows without a timestamp provided" do
    @client.set(@table_name, "row2", {"col1:cell1" => "col1-cell1-value", "col1:cell2" => "col1-cell2-value" }).should be_true
    row2 = @client.show_row(@table_name, "row2")

    lambda {
      @client.delete_row(@table_name, 'row2').should be_true
    }.should_not raise_error

    lambda {
      @client.show_row(@table_name, 'row2')
    }.should raise_error(Stargate::RowNotFoundError)
  end

end
