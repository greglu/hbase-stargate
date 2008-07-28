hbase-ruby is a pure ruby client for HBase using REST interface

== USAGE

First launch HBase:

1.
{{{
bin/start-hbase.sh
}}}

2. ruby code
{{{
require 'lib/hbase'

client = HBase::Client.new("http://localhost:60010/api") # this url is the default.
tables = client.list_tables                              # list available tables

table = client.show_table('users')                       # show the meta info of table users 

row = client.show_row('users', 'sishen')                 # show the data of row 'sishen' in table 'users'

row2 = client.create_row('users', 'sishen', Time.now.to_i, {:name => 'habbit:football', :value => 'i like football'}) # create the row 'sishen' with the data in the table 'users'

client.delete_row('users', 'sishen', nil, 'habbit:football')  # delete the row 'sishen' of table 'users' with the optional column 'habbit:football'
}}}


== INSTALLTION
 build the gem:

  rake gem

and install the versioned gem:

  gem install pkg/hbase-ruby-x.x.x.gem 

== Copyright

Copyright (c) 2007 Dingding Ye <yedingding@gmail.com>
Distributed under MIT License
