# for non-blocking direct sql db connections
require 'mysql2/em_fiber'
config['db'] = EM::Synchrony::ConnectionPool.new(:size => config['db_connection_pool_size']) do
  ::Mysql2::EM::Fiber::Client.new(:host => '10.15.100.246',
                                  :username => 'gserver_stage',
                                  :password => 'zaCrudre6U',
                                  :database => 'gserver_staging',
                                  :socket => nil,
                                  :reconnect => true)
end

#
# memcached connection pool
#

require 'em-synchrony/em-remcached'

config['memcache'] = EM::Synchrony::ConnectionPool.new(size:config['memcache_connection_pool_size']) do
  conn = Memcached.connect %w(localhost:11211)
end


# temporarily disabling mongo in staging, until we actually have a mongo instance we can use there.

=begin
# mongo db connection
require 'em-synchrony/em-mongo'
require 'mongoid'

config['mongo'] = EM::Synchrony::ConnectionPool.new(size:config['mongo_connection_pool_size']) do
  conn = EM::Mongo::Connection.new('localhost', 27017, 1, {:reconnect_in => 1})
  conn.db('mobage_development')
end


# mongoid setup...  all access is synchronous

#config['mongoid'] = EM::Synchrony::ConnectionPool.new(size:config['mongo_connection_pool_size']) do
mongoid_conn = Mongo::Connection.new 'localhost', 27017, :pool_size => config['mongo_connection_pool_size']
Mongoid.configure do |config|
  config.master = mongoid_conn.db('mobage_development')
end
#end

=end