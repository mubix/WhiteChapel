#!/usr/bin/env ruby
require	'rubygems'
require 'sinatra'
require 'haml'
require 'tire'
require 'rex'

helpers do
	Tire.configure do
		#elasurl = File.read('elastic.conf') {|f| f.readline}
		elasurl = File.open("elastic.conf").first
		url("#{elasurl.chomp}/")
		#url 'http://192.168.92.100:9200/'
	end

	Tire.index 'connectivitytest' do
		delete
		create
		store :title => 'One',   :tags => ['ruby'],           :published_on => '2011-01-01'
		store :title => 'Two',   :tags => ['ruby', 'python'], :published_on => '2011-01-02'
		delete
	end
end

get '/' do
	#haml :header
	erb :search
end


# john ./johnfile.txt --show=LEFT --format=NT