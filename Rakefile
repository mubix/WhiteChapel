require 'bundler/setup'
Bundler.require(:default)

require './importer'
require 'resque/tasks'

Resque.redis = '127.0.0.1:6379'

task "resque:setup" do
	ENV['QUEUE'] = '*'
end

desc "Alias for resque:word (To run workers on Heroku"
task "jobs:work" => "resque:work"
