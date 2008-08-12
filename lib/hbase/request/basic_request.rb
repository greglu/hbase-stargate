require 'cgi'

module HBase
  module Request
    class BasicRequest
      attr_reader :path

      def initialize(path)
        @path = path
      end
    end
  end
end
