module Stargate
  module Model
    class Row < Record
      attr_accessor :table_name
      attr_accessor :name
      attr_accessor :total_count
      attr_accessor :columns_map

      def initialize(params)
        super
        @columns_map = {} if @columns_map.nil?
      end

      def [](column_name)
        columns_map[column_name]
      end

      def columns
        columns_map.values
      end
    end
  end
end
