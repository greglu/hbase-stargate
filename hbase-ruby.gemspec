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
  s.files    = File.open("Manifest.txt").readlines.collect { |l| l.strip! }
  s.rdoc_options = ["--main", "README.txt"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
end
