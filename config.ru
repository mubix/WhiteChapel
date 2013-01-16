require './app.rb'
require 'resque/server'

run Rack::URLMap.new \
	"/"	=> Sinatra::Application,
	"/resque" => Resque::Server.new
