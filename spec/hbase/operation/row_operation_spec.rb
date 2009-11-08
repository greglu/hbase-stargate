require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Operation::RowOperation do
  before :all do
    url = ENV["HBASE_URL"].nil? ? "http://localhost:8080" : ENV["HBASE_URL"]
    @client = HBase::Client.new(url)

    table = @client.create_table("test-hbase-ruby", "col1")
  end

  it "should create a row called 'row1'" do
    lambda {
      @client.create_row("test-hbase-ruby", "row1", nil, { :name => "col1:", :value => "row1-col1" }).should be_true
    }.should_not raise_error
  end

  it "should create a row named 'row2' with timestamp value" do
    timestamp = (Time.now - (5*60)).to_i
    lambda {
      @client.create_row("test-hbase-ruby", "row2", timestamp, { :name => "col1:cell1", :value => "row2-col1-cell1" }).should be_true
    }.should_not raise_error

    row = @client.show_row("test-hbase-ruby", "row2")
    row.should be_a_kind_of(HBase::Model::Row)
    row.name.should == "row2"

    columns = row.columns
    columns.size.should == 1
    columns.first.name.should == "col1:cell1"
    columns.first.value.should == "row2-col1-cell1"
    columns.first.timestamp.should == timestamp
  end

  it "should show the rows 'row1'" do
    row = @client.show_row("test-hbase-ruby", "row1")
    row.should.is_a? HBase::Model::Row
    row.table_name.should == "test-hbase-ruby"
    row.name.should == "row1"
    row.columns.size.should == 1
    row.columns.each do |col|
      col.should.is_a? HBase::Model::Column
      col.name.should == "col1:"
      col.value.should == "row1-col1"
    end
  end

  it "should delete the rows 'row1'" do
    lambda {
      row1 = @client.delete_row('test-hbase-ruby', 'row1').should be_true
    }.should_not raise_error

    lambda {
      row_verify = @client.show_row('test-hbase-ruby', 'row1')
    }.should raise_error
  end

  after :all do
    table = @client.destroy_table("test-hbase-ruby")
  end
end
