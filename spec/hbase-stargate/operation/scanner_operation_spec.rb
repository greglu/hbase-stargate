require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Operation::ScannerOperation do
  before :all do
    url = ENV["STARGATE_URL"].nil? ? "http://localhost:8080" : ENV["STARGATE_URL"]
    @client = Stargate::Client.new(url)

    table = @client.create_table("test-stargate-client", "col1")

    @client.create_row('test-stargate-client', 'row1', nil, {:name => 'col1:', :value => "row1-col1"})
    @client.create_row('test-stargate-client', 'row2', nil, {:name => 'col1:', :value => "row2-col1"})
    @client.create_row('test-stargate-client', 'row3', nil, {:name => 'col1:', :value => "row3-col1"})
  end

  it "should throw TableNotFoundError if a scanner is requested for an non-existant table" do
    lambda {
      scanner = @client.open_scanner("test-nonexistant-table")
    }.should raise_error
  end

  it "should open a scanner and close it successfully" do
    scanner = @client.open_scanner("test-stargate-client")
    scanner.should.is_a? Stargate::Model::Scanner

    lambda {
      URI.parse("scanner.scanner_url")
    }.should_not raise_error

    lambda {
      @client.close_scanner(scanner).should be_true
    }.should_not raise_error
  end

  it "should scan the whole table when given no options and no limit" do
    scanner = @client.open_scanner("test-stargate-client")

    rows = @client.get_rows(scanner)
    rows.size.should == 3
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["row1", "row2", "row3"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should scan the whole table but limit the results when given a limit" do
    scanner = @client.open_scanner("test-stargate-client")

    rows = @client.get_rows(scanner, 2)
    rows.size.should == 2
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["row1", "row2"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should return all rows when given a batch size larger than the number of rows" do
    scanner = @client.open_scanner("test-stargate-client", {:batch => 5})

    rows = @client.get_rows(scanner)
    rows.size.should == 3
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["row1", "row2", "row3"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  it "should scan the correct row when given a start_row" do
    scanner = @client.open_scanner("test-stargate-client", {:start_row => "row2", :batch => 5})

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
    scanner = @client.open_scanner("test-stargate-client", {:end_row => "row3", :batch => 5})

    rows = @client.get_rows(scanner)
    rows.size.should == 2
    rows.each do |row|
      row.should be_an_instance_of Stargate::Model::Row
      ["row1", "row2"].should include(row.name)
    end

    @client.close_scanner(scanner).should be_true
  end

  after :all do
    @client.destroy_table("test-stargate-client")
  end
end
