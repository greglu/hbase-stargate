module HBase
  module Request
    class MetaRequest < BasicRequest
      def initialize
        super("/")
      end

      def list_tables
        self
      end
    end
  end
end
