#!/usr/bin/env ruby
$:<< '../lib' << 'lib'

require 'goliath'

class Streaming

  class Get < Goliath::API
    use Goliath::Rack::Params

    use Goliath::Rack::Render, 'json'
    use Goliath::Rack::Heartbeat
    use Goliath::Rack::Validation::RequestMethod, %w(GET)

    def on_close(env)
      # This is just to make sure if the Heartbeat fires we don't try
      # to close a connection.
      return unless env['subscription']

      env.channel.unsubscribe(env['subscription'])
      env.logger.info "Stream connection closed."
    end

    def response(env)
      env.logger.info "Stream connection opened"

      env['subscription'] = env.channel.subscribe do |msg|
        env.stream_send(msg)
      end

      [200, {}, Goliath::Response::STREAMING]
    end
  end



end