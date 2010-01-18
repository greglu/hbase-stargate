require 'spec/rake/spectask'

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "hbase-stargate"
    gemspec.authors = ['Ye Dingding', 'Openplaces']
    gemspec.email = 'greg.lu@gmail.com'
    gemspec.homepage = "http://github.com/greglu/stargate-client"
    gemspec.summary = "Ruby client for HBase's Stargate web service"
    gemspec.description = "A Ruby client used to interact with HBase through its Stargate web service front-end"
    gemspec.files = FileList["{lib,spec}/**/*","Rakefile","VERSION","LICENSE","README.textile"].to_a
    gemspec.extra_rdoc_files = FileList["LICENSE","README.textile"].to_a

    gemspec.add_development_dependency "rspec"
    gemspec.add_dependency "json"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = File.open("spec/spec.opts").readlines.map{|x| x.chomp}
end
