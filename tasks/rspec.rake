require 'rake'
require 'spec/rake/spectask'

desc "Run all examples"
Spec::Rake::SpecTask.new('examples') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:hbase) do |t|
  t.spec_files = FileList['spec/hbase/**/*_spec.rb']
  t.spec_opts = ['--color', '--format', 'specdoc']
end
