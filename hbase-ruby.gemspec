Gem::Specification.new do |s|
  s.name = %q{hbase-ruby}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ye Dingding"]
  s.date = %q{2008-08-09}
  s.description = %q{hbase-ruby is a pure ruby client for hbase and enable the ruby app enjoy the power of HBase}
  s.email = %q{yedingding@gmail.com}
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "MIT-LICENSE", "Manifest.txt", "README.txt", "Rakefile", "hbase-ruby.gemspec", "lib/hbase.rb", "lib/hbase/client.rb", "lib/hbase/exception.rb", "lib/hbase/model.rb", "lib/hbase/model/column.rb", "lib/hbase/model/column_descriptor.rb", "lib/hbase/model/region_descriptor.rb", "lib/hbase/model/row.rb", "lib/hbase/model/table_descriptor.rb", "lib/hbase/operation/meta_operation.rb", "lib/hbase/operation/row_operation.rb", "lib/hbase/operation/scanner_operation.rb", "lib/hbase/operation/table_operation.rb", "lib/hbase/request.rb", "lib/hbase/request/basic_request.rb", "lib/hbase/request/meta_request.rb", "lib/hbase/request/row_request.rb", "lib/hbase/request/scanner_request.rb", "lib/hbase/request/table_request.rb", "lib/hbase/response.rb", "lib/hbase/response/basic_response.rb", "lib/hbase/response/meta_response.rb", "lib/hbase/response/row_response.rb", "lib/hbase/response/table_response.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://sishen.lifegoo.com}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{a pure ruby client for hbase using REST interface}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
