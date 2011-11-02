
# for non-blocking direct sql db connections
if config['use_sql_direct']
  require 'mysql2/em_fiber'
  config['db'] = EM::Synchrony::ConnectionPool.new(:size => config['db_connection_pool_size']) do
    ::Mysql2::EM::Fiber::Client.new(:host => 'localhost',
                                    :username => 'root',
                                    :password => 'toor',
                                    :database => 'gserver_test',
                                    :socket => nil,
                                    :reconnect => true)
  end

else
  require "em-synchrony/activerecord"
  # for non-blocking (but synchronous) active record db connections
  ActiveRecord::Base.establish_connection(:host => 'localhost',
                                          :username => 'root',
                                          :password => 'toor',
                                          :database => 'gserver_test',
                                          :reconnect => true,
                                          :adapter => 'em_mysql2'
                                          )

  ActiveRecord::Base.connection_pool.instance_variable_set('@size', config['db_connection_pool_size'])

end
#
# memcached connection pool
#

require 'em-synchrony/em-remcached'

config['memcache'] = EM::Synchrony::ConnectionPool.new(size:config['memcache_connection_pool_size']) do
  conn = Memcached.connect %w(localhost:11211)
end


# mongo db connection
require 'em-synchrony/em-mongo'
require 'mongoid'

config['mongo'] = EM::Synchrony::ConnectionPool.new(size:config['mongo_connection_pool_size']) do
  conn = EM::Mongo::Connection.new('localhost', 27017, 1, {:reconnect_in => 1})
  conn.db('mobage_test')
end


# mongoid setup...  all access is synchronous

#config['mongoid'] = EM::Synchrony::ConnectionPool.new(size:config['mongo_connection_pool_size']) do
mongoid_conn = Mongo::Connection.new 'localhost', 27017, :pool_size => config['mongo_connection_pool_size']
Mongoid.configure do |config|
  config.master = mongoid_conn.db('mobage_test')
end
#end
