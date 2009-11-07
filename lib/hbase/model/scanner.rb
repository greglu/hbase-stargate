module HBase
  module Model
    class Scanner < Record
      AVAILABLE_OPTS = {  :start_row => "startRow", :end_row => "endRow",
                          :start_time => "startTime", :end_time => "endTime",
                          :batch => "batch" }

      attr_accessor :table_name
      attr_accessor :scanner_url
      attr_accessor :batch_size

      # Deprecation: scanner_url is used instead of just the ID
      attr_accessor :scanner_id
    end
  end
end
