module HBase
  module Request
    class ScannerRequest < BasicRequest
      attr_reader :table_name

      def initialize(table_name)
        @table_name = CGI.escape(table_name)
        path = "/#{@table_name}/scanner"
        super(path)
      end

      def open(columns, start_row = nil, stop_row = nil, timestamp = nil)

      end

      def get_rows(scanner_id, limit = 1)
        @path << "/#{scanner_id}"
      end

      def close(scanner_id)
        @path << "/#{scanner_id}"
      end
    end
  end
end
