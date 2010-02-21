module Stargate
  module Request
    class RowRequest < BasicRequest
      attr_reader :table_name
      attr_reader :name
      attr_reader :timestamp

      def initialize(table_name, name, timestamp=nil)
        @table_name, @name, @timestamp = CGI.escape(table_name), CGI.escape(name), timestamp
        super("/#{@table_name}/#{@name}")
      end

      def show(columns = nil, options = { })
        params = ""
        params << (columns ? "/#{pack_params(columns)}" : "/")
        params << "/#{@timestamp}" if @timestamp
        params << "?v=#{options[:version]}" if options[:version]
        @path + params
      end

      def create(columns = nil)
        params = ""
        params << (columns ? "/#{pack_params(columns)}" : "/")
        params << "/#{@timestamp}" if @timestamp
        @path + params
      end

      def delete(columns = nil)
        params = ""
        params << (columns ? "/#{pack_params(columns)}" : "/")
        params << "/#{@timestamp}" if @timestamp
        @path + params
      end
    end
  end
end
