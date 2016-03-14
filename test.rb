#!/usr/bin/env ruby


#credits
# http://playground.arduino.cc/Interfacing/Ruby
# https://github.com/pubnub/ruby

require 'yaml'
require 'pubnub'
require 'serialport'

# load pubnub config
config = YAML.load_file('pubnub-config.yml')
puts "config['subscribe_key']=#{config['subscribe_key']}"
puts "config['publish_key']=#{config['publish_key']}"
puts "config['channel_name']=#{config['channel_name']}"

# set up simple logger
my_logger = Logger.new(STDOUT)

# connect to pubnub
pubnub = Pubnub.new(
    subscribe_key: config['subscribe_key'],
    publish_key: config['publish_key'],
		uuid: 'riverpi', #TODO dynamically assign
    error_callback: lambda do |msg|
      puts "Error callback says: #{msg.inspect}"
    end,
    connect_callback: lambda do |msg|
      puts "CONNECTED: #{msg.inspect}"
    end,
    logger: my_logger
)


# # Lets use a callback for the first example...
# cb = lambda { |envelope| puts envelope.message }
# 
# # Asynchronous is implicitly enabled by default, if you do not provide an :http_sync option
# pubnub.publish(message: {text: "hello from the other side"}, channel: config['channel_name'], callback: cb)
# 
# 
# pubnub.history(
#   channel:  config['channel_name'],
#   count:    10,
#   reverse:  true,
#   callback: cb
# )

# pubnub.subscribe(
#   channel: config['channel_name']
# ) do |envelope|
#   puts envelope.inspect
# end




serial_config = YAML.load_file('serial-config.yml')

#params for serial port
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE
 
SerialPort.open(serial_config['port_str'], serial_config['baud_rate'], data_bits, stop_bits, parity) do |sp| 
	#just read forever
	while true do
	   while (i = sp.gets.chomp) do       # see note 2
	      puts "message: " + i
	      #puts i.class #String
				pubnub.publish(message: {text: i}, channel: config['channel_name'])
	    end
	end
end

