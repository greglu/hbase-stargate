module Stargate
  module Request
    class ScannerRequest < BasicRequest
      attr_reader :table_name

      def initialize(table_name)
        @table_name = CGI.escape(table_name)
        path = "/#{@table_name}/scanner"
        super(path)
      end

      def open
        @path
      end

      def get_rows(scanner)
        @path = URI.parse(scanner.scanner_url).path
      end

      def close(scanner)
        @path = URI.parse(scanner.scanner_url).path
      end
    end
  end
end
