module HBase
  module Request
    class MetaRequest < BasicRequest
      def initialize
        super("")
      end

      def list_tables
        @path << "/"
      end

      def create_table
        @path << "/tables"
      end
    end
  end
end
