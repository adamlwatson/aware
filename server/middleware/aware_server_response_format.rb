require 'yajl'
#require 'ruby-debug'

require 'helpers/aware_server_error'

module Goliath
  module Rack
    class AwareServerResponseFormat
      include Goliath::Rack::AsyncMiddleware

      def post_process(env, status, headers, body)
        # if success, status should be 200 and body should be an array of json objects (result rows)
        # if http error, status will be non-200 and body will be an array, possibly containing some non-mobage core error from http_router
        # if internal error, status will be non-200, but body will be a single json object in mobage-core-error format: {'error_code':some_code, 'error':'some message'}

        #puts "status: #{status}"
        #puts "headers: #{headers}"
        #puts "body: #{body}"

        case status
          when 200
            resp = {'success'=>true, 'result_count' => body.count, 'result'=>body}
            body.empty? ? status = 404 : nil
          else
            err = nil
            if body.empty? || !body.include?('error_code')
              # prep an error code and a body since we don't have anything to send back in our current body
              case status
                when 404
                  err = AwareServer::Error.new(AwareServer::Error::ERROR_API_NOT_FOUND)
                when 405
                  err = AwareServer::Error.new(AwareServer::Error::ERROR_INVALID_REQUEST_METHOD)
                else
                  err = AwareServer::Error.new(AwareServer::Error::ERROR_UNKNOWN)
              end
            end

            body = err.nil? ? body : {'error_code' => err.code, 'error' => err.to_s}
            resp = {'success'=>false, 'result'=>body}
        end

        [status, headers, resp]
      end

    end
  end
end