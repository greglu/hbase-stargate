module HBase
  module Model
    class TableDescriptor < Record
      attr_reader :name
      attr_reader :column_families
    end
  end
end
