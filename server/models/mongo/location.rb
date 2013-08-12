require 'models/mongo/mongo_model_base'

class Location < MongoModelBase

  def initialize
    @cache_key = "LOCATION"
    @cache_key_version = "A"
    @coll = db.collection("locations")
    @fields = []

    # following will only create if the index doesn't already exist
    @coll.create_index([['location', EM::Mongo::GEO2D]], :min => -500, :max => 500)
  end

  def all
    @coll.find({})
  end

  def find(qry)
    result = custom_query_with_cache(qry, "FIND", qry.to_s) # can also pass ttl as 4th param
  end

  def near
    @coll.find( { :location => { "$near" => [39.76904, -122.4835193], "$maxDistance" => 1 } }, { :limit => 1 } )
  end

  def populate
    insert_resp = @coll.safe_insert({ :label => "Close to Golden Gate Park", :location => [37.7869, -122.4867] } )
    insert_resp.callback { puts('Insert was successful') }
    insert_resp.errback { |err|  puts('An error occurred during insert: #{err}') }
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