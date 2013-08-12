require 'rack-oauth2-server'

module Goliath
  module Rack
    class RackOAuth2Server
      include Goliath::Rack::AsyncMiddleware
      use Rack::OAuth2::Server

      def initialize(app)
        @@oauth = Rack::OAuth2::Server.new(app, {
          :database => config["mongo"]

        })
        super(app)
      end

      def call(env)
        env.logger.info "Oauth2: %{%s}" % [ @@oauth ]

        #env.logger.info %{%s - "%s %s%s"} % [
        #  env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        #  ]


        super(env)
      end
    end
  end
end