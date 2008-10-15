module HBase
  module Request
    class TableRequest < BasicRequest
      attr_reader :name
      attr_reader :body

      def initialize(name)
        super("")
        @name = CGI.escape(name) if name
      end

      def show
        member_path
      end

      def regions(start_row = nil, end_row = nil)
        #TODO no handle the args!
        member_path << "/regions"
      end

      def create
        @path << "/"
      end

      def update
        member_path
      end

      def enable
        member_path << "/enable"
      end

      def disable
        member_path << "/disable"
      end

      def delete(columns = nil)
        if columns
          if columns.is_a? String
            columns = [columns]
          elsif columns.is_a? Array
          else
            raise StandardError, "Only String or Array type allows for columns"
          end
          params = columns.collect { |column| "column=#{column}" }.join('%')
          member_path << "?#{params}"
        end
        @path
      end
      
      private
        
        def member_path
          @path << "/#{name}"
          @path
        end
    end
  end
end
