module Stargate
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

require 'stargate/model/column'
require 'stargate/model/column_descriptor'
require 'stargate/model/region_descriptor'
require 'stargate/model/row'
require 'stargate/model/table_descriptor'
require 'stargate/model/scanner'
