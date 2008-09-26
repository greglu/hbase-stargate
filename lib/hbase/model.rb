module HBase
  module Model
    class Record
      def initialize (params)
        params.each do |key, value|
          name = key.to_s
          instance_variable_set("@#{name}", value) if respond_to?(name)
        end
      end
    end
  end
end

require 'hbase/model/column'
require 'hbase/model/column_descriptor'
require 'hbase/model/region_descriptor'
require 'hbase/model/row'
require 'hbase/model/table_descriptor'
