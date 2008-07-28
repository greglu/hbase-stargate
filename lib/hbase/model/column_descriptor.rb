module HBase
  module Model
    module CompressionType
      NONE = "NONE"
      RECORD = "RECORD"
      BLOCK = "BLOCK"

      def to_compression_type(type_string)
        case type_string
        when "NONE"   then NONE
        when "RECORD" then RECORD
        when "BLOCK"  then BLOCK
        else
          NONE
        end
      end

      module_function :to_compression_type
    end

    class ColumnDescriptor < Record
      attr_reader :name
      attr_reader :compression
      attr_reader :bloomfilter
      attr_reader :maximum_cell_size
      attr_reader :max_versions
    end
  end
end
