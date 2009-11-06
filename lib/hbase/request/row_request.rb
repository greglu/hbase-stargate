module HBase
  module Request
    class RowRequest < BasicRequest
      attr_reader :table_name
      attr_reader :name
      attr_reader :timestamp

      def initialize(table_name, name, timestamp=nil)
        @table_name, @name, @timestamp = CGI.escape(table_name), CGI.escape(name), timestamp
        path = "/#{@table_name}/#{@name}"
        super(path)
      end

      def show(columns = nil, options = { })
        if columns
          @path << "/#{pack_params(columns)}"
        end
        @path << "/#{@timestamp}" if @timestamp

        @path << "?"
        @path << "&v=#{options[:version]}" if options[:version]

        @path
      end

      def create
        @path
      end

      def delete(columns = nil)
        @path << "/#{pack_params(columns)}" if columns
        @path << "/#{@timestamp}" if @timestamp
        @path
      end
    end
  end
end
