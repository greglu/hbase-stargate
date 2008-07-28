module HBase
  module Model
    module CompressionType
      NONE = "NONE"
      RECORD = "RECORD"
      BLOCK = "BLOCK"
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
