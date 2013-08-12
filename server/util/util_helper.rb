# encoding: utf-8
require "amq/client/adapters/event_machine"
require "amq/client/queue"
require "amq/client/exchange"

=begin
if RUBY_VERSION.to_s =~ /^1.9/
  Encoding.default_internal = Encoding::UTF_8
  Encoding.default_external = Encoding::UTF_8
end
=end

def init_util(description = "", &block)

  EM.run do

    config_amqp = {
      :host => 'localhost',
      :port => '5672',
      :user => 'guest',
      :pass => 'guest',
      :vhost => '/',
      :frame_max => 65535,
      :heartbeat_interval => 1
    }

    AMQ::Client::EventMachineClient.connect(config_amqp) do |client|
      begin
        puts
        puts "=============> #{description}"

        block.call(client)
      rescue Interrupt
        warn "Manually interrupted, terminating ..."
      rescue Exception => exception
        STDERR.puts "\n\e[1;31m[#{exception.class}] #{exception.message}\e[0m"
        exception.backtrace.each do |line|
          line = "\e[0;36m#{line}\e[0m" if line.match(Regexp::quote(File.basename(__FILE__)))
          STDERR.puts "  - " + line
        end
      end
    end
  end
end
