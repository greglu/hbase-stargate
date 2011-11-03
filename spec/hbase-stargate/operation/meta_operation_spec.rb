require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Stargate::Operation::MetaOperation do

  before do
    url = ENV["STARGATE_URL"].nil? ? "http://localhost:8080" : ENV["STARGATE_URL"]
    @client = Stargate::Client.new(url)
  end

  it "should return ConnectionNotEstablishedError when server cannot be connected to" do
    lambda {
      Stargate::Client.new("http://doesntexist.local:8080").list_tables
    }.should raise_error(Stargate::ConnectionNotEstablishedError)
  end

  it "should return tables" do
    tables = @client.list_tables
    tables.should respond_to(:size)
    tables.each do |table|
      table.should.is_a? Stargate::Model::TableDescriptor
    end
  end

end
