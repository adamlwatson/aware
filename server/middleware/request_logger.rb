module Goliath
  module Rack
    class RequestLogger
      include Goliath::Rack::AsyncMiddleware

      def initialize(app)
        super(app)
      end

      def call(env)
        env.logger.info %{%s - "%s %s%s"} % [
          env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
          env["REQUEST_METHOD"],
          env["PATH_INFO"],
          env["QUERY_STRING"].empty? ? "" : "?"+env["QUERY_STRING"]
        ]
        super(env)
      end
    end
  end
end