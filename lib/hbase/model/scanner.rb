module HBase
  module Model
    class Scanner < Record
      attr_accessor :table_name
      attr_accessor :scanner_id
    end
  end
end
