require 'models/mongo/mongo_model_base'

class Location < MongoModelBase

  def initialize
    @cache_key = "LOCATION"
    @cache_key_version = "A"
    @coll = db.collection("locations")
    @fields = []
  end

  def all
    @coll.find({})
  end

  def find(qry)

    rows = query_with_cache(qry, "FIND", qry.to_s) # can also pass ttl as 4th param

  end



  def test

    #resp = @coll.afind({}).to_a #async

    # example of safe inserts...
=begin
    insert_resp = @coll.safe_insert( {:foo => "burr" } )
    insert_resp.callback { env.logger.info('Insert was successful') }
    insert_resp.errback { |err|  env.logger.info('An error occurred during insert: #{err}') }
=end

    # returns all docs except "foo"=>"hello"
    #resp = @coll.find("foo" => /ba/)

    # a couple of conditional queries
    #resp = @coll.find({ "$or" => [{"foo" => {"$in" => ["bar", "baz"]}}, {"baz" => "bat"} ] })
    #resp = @coll.find({ "foo" => {"$in" => ["bar", "baz"]}})


  end

end