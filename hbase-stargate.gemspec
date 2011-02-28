# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'stargate/version'

Gem::Specification.new do |s|
  s.name = "hbase-stargate"
  s.version     = Stargate::VERSION
  s.authors = ["Hopper"]
  s.summary = %q{Ruby client for HBase's Stargate web service}
  s.description = %q{A Ruby client used to interact with HBase through its Stargate web service front-end}
  s.email = %q{greg.lu@gmail.com}
  s.homepage = %q{http://github.com/greglu/hbase-stargate}

  s.platform    = Gem::Platform::RUBY
  s.required_rubygems_version = ">= 1.3.6"

  s.files = Dir.glob("lib/**/*") + %w(LICENSE README.textile Rakefile)
  s.test_files = Dir.glob("spec/**/*")
  s.require_paths = ["lib"]

  s.add_dependency(%q<json>, [">= 0"])
  s.add_development_dependency "rspec"
end
