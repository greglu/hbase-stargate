module HBase
  module Operation
    module MetaOperation
      def list_tables
        request = Request::MetaRequest.new
        tables = Response::MetaResponse.new(get(request.list_tables), :list_tables).parse
      end
    end
  end
end
