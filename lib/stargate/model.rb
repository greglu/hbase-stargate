module Stargate
  module Model
    class Record
      def initialize (params)
        params.each do |key, value|
          set_function = key.to_s + "="
          send(set_function, value) if respond_to?(set_function)
        end
      end
    end
  end
end

require File.dirname(__FILE__) + '/model/column'
require File.dirname(__FILE__) + '/model/column_descriptor'
require File.dirname(__FILE__) + '/model/region'
require File.dirname(__FILE__) + '/model/row'
require File.dirname(__FILE__) + '/model/table_descriptor'
require File.dirname(__FILE__) + '/model/scanner'
