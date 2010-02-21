module Stargate
  module Model
    class Scanner < Record
      AVAILABLE_OPTS = {  :start_row => "startRow", :end_row => "endRow",
                          :start_time => "startTime", :end_time => "endTime",
                          :batch => "batch" }

      attr_accessor :table_name
      attr_accessor :scanner_url
      attr_accessor :batch_size

      def scanner_id
        warn "[DEPRECATION] scanner_url is now used instead of scanner_id. "
      end

      def scanner_id=(id=nil)
        scanner_id
      end
    end
  end
end
