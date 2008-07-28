module HBase
  module Model
    class Row < Record
      attr_reader :name
      attr_reader :timestamp
      attr_reader :columns
    end
  end
end
