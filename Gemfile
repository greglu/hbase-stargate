source :rubygems

platforms :ruby do
  gem "yajl-ruby"
end

platforms :jruby do
  gem "json"
end

group :test do
  gem "rspec"
  gem 'ruby-debug', :platforms => :ruby_18
  gem 'ruby-debug19', :require => 'ruby-debug'
end
