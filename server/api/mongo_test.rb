require 'goliath'
require 'yajl'

class MongoTest < Goliath::API
  use Goliath::Rack::Params  # parse params
  use Goliath::Rack::Render, 'json'  # auto-negotiate and format json responses

  def on_body(env, data)
    env.logger('test')
    env.logger.info 'received data: ' + data
  end

  def response(env)

    coll = mongo.collection('test')

    # returns all docs in coll "test" in db "mobage_development"
    #resp = coll.afind({}).to_a

    #resp = coll.find({})

    # example of safe inserts...
=begin
    insert_resp = coll.safe_insert( {:foo => "burr" } )
    insert_resp.callback { env.logger.info('Insert was successful') }
    insert_resp.errback { |err|  env.logger.info('An error occurred during insert: #{err}') }
=end

    # returns all docs except "foo"=>"hello"
    #resp = coll.find("foo" => /ba/)

    # a couple of conditional queries
    resp = coll.find({ "$or" => [{"foo" => {"$in" => ["bar", "baz"]}}, {"baz" => "bat"} ] })
    #resp = coll.find({ "foo" => {"$in" => ["bar", "baz"]}})

    [200, {}, resp]
  end
end

