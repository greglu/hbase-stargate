require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Operation::ScannerOperation do
  before :all do
    url = ENV["STARGATE_URL"].nil? ? "http://localhost:8080" : ENV["STARGATE_URL"]
    @client = Stargate::Client.new(url)

    table = @client.create_table("test-hbase-stargate", "col1")

    @client.create_row('test-hbase-stargate', 'row1', nil, {:name => 'col1:', :value => "row1-col1"})
    @client.create_row('test-hbase-stargate', 'row2', nil, {:name => 'col1:', :value => "row2-col1"})
    @client.create_row('test-hbase-stargate', 'row3', nil, {:name => 'col1:', :value => "row3-col1"})

    scan_table = @client.create_table("test-hbase-stargate-scan", "col1")

    @ts1 = (Time.now - (5*60)).to_i
    @client.create_row("test-hbase-stargate-scan", "rowts11", @ts1, { :name => "col1:", :value => "rowts11-col1-cell1" }).should be_true
    @client.create_row("test-hbase-stargate-scan", "rowts12", @ts1, { :name => "col1:", :value => "rowts12-col1-cell1" }).should be_true

    @ts2 = (Time.now - (5*60)).to_i + 1000
    @client.create_row("test-hbase-stargate-scan", "rowts21", @ts2, { :name => "col1:", :value => "rowts21-col1-cell1" }).should be_true
    @client.create_row("test-hbase-stargate-scan", "rowts22", @ts2, { :name => "col1:", :value => "rowts22-col1-cell1" }).should be_true

    @ts3 = (Time.now - (5*60)).to_i + 2000
    @client.create_row("test-hbase-stargate-scan", "rowts31", @ts3, { :name => "col1:", :value => "rowts31-col1-cell1" }).should be_true
    @client.create_row("test-hbase-stargate-scan", "rowts32", @ts3, { :name => "col1:", :value => "rowts32-col1-cell1" }).should be_true

    @ts4 = (Time.now - (5*60)).to_i + 3000
  end

  it "should throw TableNotFoundError if a scanner is requested for an non-existant table" do
    lambda {
      scanner = @client.open_scanner("test-nonexistant-table")
    }.should raise_error
  end

  it "should open a scanner and close it successfully" do
    scanner = @client.open_scanner("test-hbase-stargate")
    scanner.should.is_a? Stargate::Model::Scanner

    lambda {
      URI.parse("scanner.scanner_url")
    }.should_not raise_error

    lambda {
      @client.close_scanner(scanner).should be_true
    }.should_not raise_error
  end

  it "should scan the whole table when given no options and no limit" do
    scanner = @client.open_scanner("test-hbase-stargate")

    rows = @client.get_rows(scanner)
    rows.size.should == 3
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["row1", "row2", "row3"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should scan the whole table but limit the results when given a limit" do
    scanner = @client.open_scanner("test-hbase-stargate")

    rows = @client.get_rows(scanner, 2)
    rows.size.should == 2
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["row1", "row2"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should return all rows when given a batch size larger than the number of rows" do
    scanner = @client.open_scanner("test-hbase-stargate", {:batch => 5})

    rows = @client.get_rows(scanner)
    rows.size.should == 3
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["row1", "row2", "row3"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should scan the correct row when given a start_row" do
    scanner = @client.open_scanner("test-hbase-stargate", {:start_row => "row2", :batch => 5})

    rows = @client.get_rows(scanner)
    rows.size.should == 2
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["row2", "row3"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should scan the correct row when given an end_row" do
    # The end_row defined is exclusive, i.e. end_row does not get returned in scanner
    scanner = @client.open_scanner("test-hbase-stargate", {:end_row => "row3", :batch => 5})

    rows = @client.get_rows(scanner)
    rows.size.should == 2
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["row1", "row2"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should scan all 6 rows when given first timestamp" do
    scanner = @client.open_scanner("test-hbase-stargate-scan", {:start_time => @ts1})
    rows = @client.get_rows(scanner)
    rows.size.should == 6
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["rowts11","rowts12","rowts21","rowts22","rowts31","rowts32"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should scan last 2 rows when given last timestamp as start" do
    scanner = @client.open_scanner("test-hbase-stargate-scan", {:start_time => @ts3})
    rows = @client.get_rows(scanner)
    rows.size.should == 2
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["rowts31","rowts32"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should scan first 4 rows when given middle timestamp as end" do
    scanner = @client.open_scanner("test-hbase-stargate-scan", {:start_time => @ts1, :end_time => @ts3})
    rows = @client.get_rows(scanner)
    rows.size.should == 4
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["rowts11","rowts12","rowts21","rowts22"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should scan last 4 rows when given start and end timestamp" do
    scanner = @client.open_scanner("test-hbase-stargate-scan", {:start_time => @ts2, :end_time => @ts4})
    rows = @client.get_rows(scanner)
    rows.size.should == 4
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["rowts21","rowts22","rowts31","rowts32"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  after :all do
    @client.destroy_table("test-hbase-stargate")
    @client.destroy_table("test-hbase-stargate-scan")
  end
end
