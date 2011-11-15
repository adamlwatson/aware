require 'goliath'

class Locations

  class Get < Goliath::API

    use Goliath::Rack::Params  # parse params
    use Goliath::Rack::Render, 'json'  # auto-negotiate and format json responses

    def response(env)

      #resp = MongoidTest.count(conditions: {foo: /blah*/})
      loc = Location.new
      resp = loc.find({})
      #resp = loc.find({:label => /.*/})
      #resp = loc.find_by_label("Golden Gate Park")

      [200, {}, resp]
    end
  end

  class Populate < Goliath::API
    use Goliath::Rack::Params
    use Goliath::Rack::Render, 'json'

    def response(env)

      l1 = Location.new( label: 'Golden Gate Park' )
      #l1.current_location = [:lat =>  37.7690400, :lng => -122.4835193] #
      l1.location = [37.7690400, -122.4835193] #

      l2 = Location.new( label: 'Balboa Park SD' )
      #l2.current_location = [:lat =>  32.7343822, :lng => -117.1441227] #
      l2.location = [32.7343822, -117.1441227] #

      l3 = Location.new( label: 'AT&T Park' )
      #l2.current_location = [:lat =>  32.7343822, :lng => -117.1441227] #
      l3.location = [37.77859, -122.38898] #


      l1.save
      l2.save
      l3.save

      [200, {}, []]
    end


  end
end
