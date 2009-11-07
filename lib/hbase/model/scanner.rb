module HBase
  module Model
    class Scanner < Record
      AVAILABLE_OPTS = {  :start_row => "startRow", :end_row => "endRow",
                          :start_time => "startTime", :end_time => "endTime",
                          :batch => "batch" }

      attr_accessor :table_name
      attr_accessor :scanner_id
      attr_accessor :scanner_url
    end
  end
end
