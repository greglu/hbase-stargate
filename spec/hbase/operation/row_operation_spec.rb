require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe HBase::Operation::RowOperation do
  before :all do
    url = ENV["HBASE_URL"].nil? ? "http://localhost:60050/api" : ENV["HBASE_URL"]
    @client = HBase::Client.new(url)

    table = @client.create_table("test-hbase-ruby", "col1")
  end

  it "should create two rows called 'row1'" do
    lambda {
      row2 = @client.create_row("test-hbase-ruby", "row1", nil, { :name => "col1:", :value => "row1-col1" })
    }.should_not raise_error
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
      row1 = @client.delete_row('test-hbase-ruby', 'row1')
    }.should_not raise_error
  end

  after :all do
    table = @client.destroy_table("test-hbase-ruby")
  end
end
