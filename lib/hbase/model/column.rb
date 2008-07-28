module HBase
  module Model
    class Column < Record
      attr_accessor :name
      attr_accessor :value
    end
  end
end
