module Stargate
  module Model
    class TableDescriptor < Record
      attr_accessor :name
      attr_accessor :column_families
    end
  end
end
