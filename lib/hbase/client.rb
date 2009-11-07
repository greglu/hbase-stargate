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

    def initialize(url = "http://localhost:8080", opts = {})
      @url = URI.parse(url)
      unless @url.kind_of? URI::HTTP
        raise "invalid http url: #{url}"
      end

      # Not actually opening the connection yet, just setting up the persistent connection.
      @connection = Net::HTTP.new(@url.host, @url.port)
      @connection.read_timeout = opts[:timeout] if opts[:timeout]
    end

    def get(path)
      safe_request { @connection.get(@url.path + path, {"Accept" => "application/json"}) }
    end

    # Needed for scanner functionality
    def get_response(path)
      safe_response { @connection.get(@url.path + path, {"Accept" => "application/json"}) }
    end

    def post(path, data = nil)
      safe_request { @connection.post(@url.path + path, data, {'Content-Type' => 'text/xml'}) }
    end

    # Needed for scanner functionality
    def post_response(path, data = nil)
      safe_response { @connection.post(@url.path + path, data, {'Content-Type' => 'text/xml'}) }
    end

    def delete(path)
      safe_request { @connection.delete(@url.path + path) }
    end

    # Needed for scanner functionality
    def delete_response(path)
      safe_response { @connection.delete(@url.path + path) }
    end

    def put(path, data = nil)
      safe_request { @connection.put(@url.path + path, data, {'Content-Type' => 'text/xml'}) }
    end

    private

      # Part of safe_request was broken up into safe_response because when working with scanners
      # in Stargate, you need to have access to the response itself, and not just the body.
      def safe_response(&block)
        begin
          yield
        rescue Errno::ECONNREFUSED
          raise ConnectionNotEstablishedError, "can't connect to #{@url}"
        rescue Timeout::Error => e
          puts e.backtrace.join("\n")
          raise ConnectionTimeoutError, "execution expired. Maybe query disabled tables"
        end
      end

      def safe_request(&block)
        response = safe_response{ yield block }

        case response
        when Net::HTTPSuccess
          response.body
        else
          response.error!
        end
      end

  end
end
