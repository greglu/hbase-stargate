module HBase
  module Request
    class MixRequest < BasicRequest
      def initialize
        super("/")
      end

      def list_tables
        self
      end
    end
  end
end
