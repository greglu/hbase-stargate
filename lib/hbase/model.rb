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

require File.dirname(__FILE__) + '/model/column'
require File.dirname(__FILE__) + '/model/column_descriptor'
require File.dirname(__FILE__) + '/model/region_descriptor'
require File.dirname(__FILE__) + '/model/row'
require File.dirname(__FILE__) + '/model/table_descriptor'
require File.dirname(__FILE__) + '/model/scanner'
