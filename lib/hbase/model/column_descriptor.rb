module HBase
  module Model
    module CompressionType
      NONE = "NONE"
      RECORD = "RECORD"
      BLOCK = "BLOCK"

      CTYPES = [NONE, RECORD, BLOCK]

      def to_compression_type(type_string)
        CTYPES.include?(type_string) ? type_string : NONE
      end

      module_function :to_compression_type
    end

    class ColumnDescriptor < Record
      AVAILABLE_OPTS = { :name => "name", :max_versions => "max-versions", :compression => "compression",
                         :in_memory => "in-memory", :block_cache => "block-cache", :max_cell_size => "max-cell-size",
                         :ttl => "time-to-live", :bloomfilter => "bloomfilter"}
      attr_accessor :name
      attr_accessor :compression
      attr_accessor :bloomfilter
      attr_accessor :maximum_cell_size
      attr_accessor :max_versions
    end
  end
end
