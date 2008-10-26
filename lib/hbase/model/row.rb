module HBase
  module Model
    class Row < Record
      attr_accessor :table_name
      attr_accessor :name
      attr_accessor :timestamp
      attr_accessor :total_count
      attr_accessor :columns
    end
  end
end
