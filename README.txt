hbase-ruby is a pure ruby client for HBase (http://hadoop.apache.org/hbase). It works with the most recent version of HBase REST interface.

== INSTALLTION

$gem sources -a http://gems.github.com
$gem install sishen-hbase-ruby

For those who wants to use hbase in their rails application, can add this line to the environment.rb:
{{{
config.gem 'sishen-hbase-ruby', :lib => "hbase", :source => "http://gems.github.com"
}}}

To build the gem yourself:

$rake gem

== USAGE

First download the recent version of hbase (svn checkout http://svn.apache.org/repos/asf/hadoop/hbase/trunk hbase), compile it with 'ant', then launch HBase server:

$bin/start-hbase.sh

Here is the example:
{{{
require 'hbase'

client = HBase::Client.new("http://localhost:60010/api") # this url is the default.
tables = client.list_tables                              # list available tables

table = client.create_table('users', 'habbit')           # create a table whose column_family is habbit

table = client.show_table('users')                       # show the meta info of table users 

row = client.show_row('users', 'sishen')                 # show the data of row 'sishen' in table 'users'

row2 = client.create_row('users', 'sishen', Time.now.to_i, {:name => 'habbit:football', :value => 'i like football'}) # create the row 'sishen' with the data in the table 'users'

client.delete_row('users', 'sishen', nil, 'habbit:football')  # delete the row 'sishen' of table 'users' with the optional column 'habbit:football'
}}}

== Testing

First you want to install rspec gem:

{{{
	sudo gem install rspec
  }}}

Now, you can run the spec by following rake task:

{{{
	rake examples
  }}}

== Copyright

Copyright (c) 2008 Dingding Ye <yedingding@gmail.com>
Distributed under MIT License
