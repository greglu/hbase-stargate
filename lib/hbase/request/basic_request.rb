require 'cgi'

module HBase
  module Request
    class BasicRequest
      attr_reader :path

      def initialize(path)
        @path = path
      end


      protected

      def pack_params columns
        if columns.is_a? String
          columns = [columns]
        elsif columns.is_a? Array
        else
          raise StandardError, "Only String or Array type allows for columns"
        end

        columns.join(',')
      end
    end
  end
end
