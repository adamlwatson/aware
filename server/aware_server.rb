$:<< './' << File.dirname(__FILE__)

# common libs
require 'goliath'
require 'yajl'
require 'mongoid'
require 'rack-oauth2-server'
require 'ruby-debug'

# helpers and middleware
require 'middleware/request_logger'
#require 'middleware/rack-oauth2-server'
require 'middleware/aware_server_response_format'
require 'helpers/aware_server_error'

# api classes
require 'api/locations'

# models
require 'app/models/mongoid/location'

class RackRoutes < Goliath::API

  use Goliath::Rack::RequestLogger      # log ip/path for each incoming request

  use Goliath::Rack::Heartbeat          # respond to /status with 200, OK (for overlord monitoring, etc)
  use Goliath::Rack::DefaultMimeType    # cleanup accepted mime types
  use Goliath::Rack::Params             # parse all params in query strings

  use Goliath::Rack::Render, 'json'     # auto-negotiate json response header and response format rendering

  use Goliath::Rack::AwareServerResponseFormat # auto-formats all api responses to a standard Mobage Core spec
  #use Goliath::Rack::RackOAuth2Server

  # return all stored locations
  get 'locations' do
    run Locations::Get.new
  end

  get 'populate' do
    run Locations::Populate.new
  end

#  get '/users/:user_id(.:format)', :user_id => /\d+/ do
#    run Locations::Get.new
#  end


  # maps for specs

  map '/maptest' do
    use Goliath::Rack::Validation::RequestMethod, %w(GET POST)
    run Proc.new { |env|
      case env["REQUEST_METHOD"]
        when 'GET'
          [200, {}, ['message' => 'GET maptest'] ]
        when 'POST'
          [200, {}, ['message' => 'POST maptest'] ]
      end
    }
  end

  map '/middleware_post_test' do
    use Goliath::Rack::Validation::RequestMethod, %w(POST)
    run Proc.new {|env| [200, {}, ['message' => 'POST middleware_post_test'] ]}
  end

  map '/version' do
    run Proc.new {|env| [200, {}, ['api_version' => env.config['api_version'].to_s ] ]}
  end


  def on_headers(env, headers)

  end

  def on_close(env)

  end


  not_found('/') do
    # drop through to error response formatting in core_response_format middleware
    run Proc.new { |env| [404, {}, [] ] }
  end

end