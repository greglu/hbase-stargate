module Stargate
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
      AVAILABLE_OPTS = {  :name => "name", :max_versions => "VERSIONS", :versions => "VERSIONS",
                          :compression => "COMPRESSION", :in_memory => "IN_MEMORY",
                          :block_cache => "BLOCKCACHE", :blockcache => "BLOCKCACHE",
                          :blocksize => "BLOCKSIZE", :length => "LENGTH", :ttl => "TTL",
                          :bloomfilter => "BLOOMFILTER"}
      attr_accessor :name
      attr_accessor :compression
      attr_accessor :bloomfilter
      attr_accessor :maximum_cell_size
      attr_accessor :max_versions

      attr_accessor :versions
    end
  end
end
