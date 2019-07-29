# TODO: Write documentation for `Asteriskws`
require "kemal"
require "kemal-session"
require "dotenv"

# Add a session config secret
Kemal::Session.config.secret = "9e7abe8ae041296820a0b69ef0e4a397c87f5866f454d35d432840bc98cfd789439addc260bb6f9a058e88faa7e4a4e416e39d05273f459dd3373dc6387cf69c"

Dotenv.load
# Dotenv.load(path: "/var/www/domains/mischicanadas/subdomains/app/asteriskws/.env")

module Asteriskws
  VERSION = "0.1.0"

  # TODO: Put your code here
  
  ws_asterisk = HTTP::WebSocket.new(URI.parse("#{ENV["ASTERISKCR_ARI_WEBSOCKET"]}/ari/events?api_key=#{ENV["ASTERISKCR_ARI_USERNAME"]}:#{ENV["ASTERISKCR_ARI_SECRET"]}&app=#{ENV["ASTERISKCR_ARI_APP"]}"))
  
  # Sockets
  sockets = [] of HTTP::WebSocket

  spawn do
    
    ws "/asterisk/events" do |socket|
      sockets.push socket
      
      # Handle incoming message and dispatch it to all connected clients
      socket.on_message do |message|
        sockets.each do |a_socket|
          a_socket.send message
        end
      end

      # Handle disconnection and clean sockets
      socket.on_close do |_|
        sockets.delete(socket)
        puts "Closing Socket: #{socket}"
      end
    end

    Kemal.run(3016)
  end

  # Handle incomming messages from Asterisk
  ws_asterisk.on_message do |message|
    # Send message to all connected clients
    sockets.each do |a_socket|
      a_socket.send message
    end
  end
  ws_asterisk.run

end
