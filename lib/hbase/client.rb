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
      if opts[:proxy]
        proxy_address, proxy_port = opts[:proxy].split(':')
        @connection = Net::HTTP.Proxy(proxy_address, proxy_port).new(@url.host, @url.port)
      else
        @connection = Net::HTTP.new(@url.host, @url.port)
      end
      @connection.read_timeout = opts[:timeout] if opts[:timeout]
    end

    def get(path, options = {})
      safe_request { @connection.get(@url.path + path, {"Accept" => "application/json"}.merge(options)) }
    end

    def get_response(path, options = {})
      safe_response { @connection.get(@url.path + path, {"Accept" => "application/json"}.merge(options)) }
    end

    def post(path, data = nil, options = {})
      safe_request { @connection.post(@url.path + path, data, {'Content-Type' => 'text/xml'}.merge(options)) }
    end

    def post_response(path, data = nil, options = {})
      safe_response { @connection.post(@url.path + path, data, {'Content-Type' => 'text/xml'}.merge(options)) }
    end

    def delete(path, options = {})
      safe_request { @connection.delete(@url.path + path, options) }
    end

    def delete_response(path, options = {})
      safe_response { @connection.delete(@url.path + path, options) }
    end

    def put(path, data = nil, options = {})
      safe_request { @connection.put(@url.path + path, data, {'Content-Type' => 'text/xml'}.merge(options)) }
    end

    def put_response(path, data = nil, options = {})
      safe_response { @connection.put(@url.path + path, data, {'Content-Type' => 'text/xml'}.merge(options)) }
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
