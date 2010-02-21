module Stargate
  module Model

    class Region < Record
      AVAILABLE_OPTS = {  :name => "name", :location => "location", :id => "id",
                          :start_key => "startKey", :end_key => "endKey" }

      attr_accessor :name
      attr_accessor :location
      attr_accessor :id
      attr_accessor :start_key
      attr_accessor :end_key
    end

  end
end
