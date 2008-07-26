module HBase
  module Request
    class BasicRequest
      attr_reader :url

      def initialize(url)
        @url = url
      end
    end
  end
end
