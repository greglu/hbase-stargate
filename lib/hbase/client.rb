require 'net/http'
require 'hbase/operation/meta_operation'
require 'hbase/operation/table_operation'
require 'hbase/operation/row_operation'
require 'hbase/operation/scanner_operation'

module HBase
  class Client
    include Operation::MetaOperation
    include Operation::TableOperation
    include Operation::RowOperation
    include Operation::ScannerOperation

    attr_reader :url, :connection

    def initialize(url = "http://localhost:60010/api", opts = {})
      @url = URI.parse(url)
      unless @url.kind_of? URI::HTTP
        raise "invalid http url: #{url}"
      end

      # Not actually opening the connection yet, just setting up the persistent connection.
      @connection = Net::HTTP.new(@url.host, @url.port)
      @connection.read_timeout = opts[:timeout] if opts[:timeout]
    end

    def get(path)
      safe_request { @connection.get(@url.path + path) }
    end

    def post(path, data = nil)
      safe_request { @connection.post(@url.path + path, data, {'Content-Type' => 'text/xml'}) }
    end

    def delete(path)
      safe_request { @connection.delete(@url.path + path) }
    end

    private
    def safe_request(&block)
      response = yield
      case response
        when Net::HTTPSuccess then response.body
      else
        response.error!
      end
    end
  end
end
