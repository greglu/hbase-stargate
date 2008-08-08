Gem::Specification.new do |s|
  s.name     = "hbase-ruby"
  s.version  = "0.1"
  s.date     = "2008-08-07"
  s.summary  = "a pure ruby client for hbase using REST interface"
  s.email    = "yedingding@gmail.com"
  s.homepage = "http://github.com/sishen/hbase-ruby"
  s.description = "hbase-ruby is a pure ruby client for hbase and enable the ruby app enjoy the power of HBase"
  s.has_rdoc = true
  s.authors  = ["Dingding Ye"]
  s.files    = ["History.txt", "MIT-LICENSE", "Manifest.txt", "README.txt", "Rakefile", "hbase-ruby.gemspec", "lib/hbase.rb", "lib/hbase/client.rb", "lib/hbase/exception.rb", "lib/hbase/model.rb", "lib/hbase/model/column.rb", "lib/hbase/model/column_descriptor.rb", "lib/hbase/model/region_descriptor.rb", "lib/hbase/model/row.rb", "lib/hbase/model/table_descriptor.rb", "lib/hbase/operation/meta_operation.rb", "lib/hbase/operation/row_operation.rb", "lib/hbase/operation/scanner_operation.rb", "lib/hbase/operation/table_operation.rb", "lib/hbase/request.rb", "lib/hbase/request/basic_request.rb", "lib/hbase/request/meta_request.rb", "lib/hbase/request/row_request.rb", "lib/hbase/request/scanner_request.rb", "lib/hbase/request/table_request.rb", "lib/hbase/response.rb", "lib/hbase/response/basic_response.rb", "lib/hbase/response/meta_response.rb", "lib/hbase/response/row_response.rb", "lib/hbase/response/table_response.rb"]
  s.rdoc_options = ["--main", "README.txt"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
end
