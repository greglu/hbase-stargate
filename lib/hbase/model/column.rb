module HBase
  module Model
    class Column < Record
      attr_accessor :name
      attr_accessor :value
      attr_accessor :timestamp
    end
  end
end
