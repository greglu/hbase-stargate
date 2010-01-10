begin
  require 'jeweler'

  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "hbase-ruby"
    gemspec.authors = ['Ye Dingding', 'Openplaces']
    gemspec.email = 'greg.lu@gmail.com'
    gemspec.homepage = "http://github.com/greglu/hbase-ruby"
    gemspec.summary = "A pure ruby client for HBase using the Stargate interface."
    gemspec.description = "A pure ruby client used to interact with HBase through its Stargate interface which serves up XML, JSON, protobuf, and more."
    gemspec.files = FileList["{lib,spec,tasks}/**/*","Rakefile","VERSION","LICENSE","README.textile"].to_a
    gemspec.extra_rdoc_files = FileList["LICENSE","README.textile"].to_a

    gemspec.add_development_dependency "rspec"
    gemspec.add_dependency "json"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Dir['tasks/**/*.rake'].each { |rake| load rake }
