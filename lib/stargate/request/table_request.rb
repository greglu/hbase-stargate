module Stargate
  module Request
    class TableRequest < BasicRequest
      attr_reader :name

      def initialize(name)
        @name = CGI.escape(name) if name
        super("/#{@name}")
      end

      def show
        @path + "/schema"
      end

      def regions
        @path + "/regions"
      end

      def create
        @path + "/schema"
      end

      def update
        @path + "/schema"
      end

      def enable
        @path + "/enable"
      end

      def disable
        @path + "/disable"
      end

      def delete
        @path + "/schema"
      end

    end
  end
end
