module HBase
  module Model
    class TableDescriptor < Record
      attr_reader :name
      attr_reader :families
    end
  end
end
