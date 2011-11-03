require 'rspec/core/rake_task'
require 'bundler/gem_helper'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end
