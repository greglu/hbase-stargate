module HBase
  module Model
    class Row < Record
      attr_accessor :table_name
      attr_accessor :name
      attr_accessor :total_count
      attr_accessor :columns

      def timestamp
        warn "[DEPRECATION] timestamp attribute will be removed from the Row model. "
      end

      def timestamp=
        timestamp
      end
    end
  end
end
