module HBase
  module Operation
    module MixOperation
      def list_tables
        request = Request::MixRequest.new
        tables = Response::MixResponse.new(get(request.list_tables), :list_tables).parse
      end
    end
  end
end
