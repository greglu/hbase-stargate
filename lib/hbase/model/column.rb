module HBase
  module Model
    class Column < Record
      attr_reader :name
      attr_reader :value
    end
  end
end
