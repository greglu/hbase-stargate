module HBase
  module Request
    class MetaRequest < BasicRequest
      def initialize
        super("/")
      end

      def list_tables
        @path
      end
    end
  end
end
