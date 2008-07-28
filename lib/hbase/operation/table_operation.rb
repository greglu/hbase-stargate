module HBase
  module Operation
    module TableOperation
      def show_table(name)
        request = Request::TableRequest.new(name)
        table_descriptor = Response::TableResponse.new(get(request.show)).parse
      end

      def create_table(name, data)
      end

      def table_regions(name, start_row = nil, end_row = nil)
      end
    end
  end
end
