module Stargate
  module Model
    class Column < Record

      attr_accessor :name
      attr_accessor :value
      attr_accessor :timestamp
      attr_accessor :versions

      def versions
        @versions ||= []
      end

      def inspect
        output = "#<#{self.class.name} @name=#{name} @value=#{value} @timestamp=#{timestamp}"
        output << " @versions=#{versions}" unless versions.empty?
        output << ">"
        output
      end

    end
  end
end
