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
      AVAILABLE_OPTS = {  :name => "name", :versions => "VERSIONS",
                          :compression => "COMPRESSION", :in_memory => "IN_MEMORY",
                          :blockcache => "BLOCKCACHE", :block_cache => "BLOCKCACHE",
                          :blocksize => "BLOCKSIZE", :length => "LENGTH", :ttl => "TTL",
                          :bloomfilter => "BLOOMFILTER"}
      attr_accessor :name
      attr_accessor :compression
      attr_accessor :bloomfilter
      attr_accessor :versions
      attr_accessor :length
      attr_accessor :in_memory
      attr_accessor :ttl
      attr_accessor :blockcache
    end
  end
end
