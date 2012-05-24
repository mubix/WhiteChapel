#!/usr/bin/env ruby
require	'rubygems'
require 'sinatra'
require 'haml'

get '/' do
	haml :header
end

get '/add_hash/:type/*' do
	# process hash for processing
end

get '/upload_dump/' do
	haml :upload_dump
end

post '/upload_dump/' do
	unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
		@error = "No file selected"
		return haml :upload_dump
	end
	STDERR.puts "Uploading file, original name #{name.inspect}"
	while blk = tmpfile.read(65536)
		blk.each do |line|
=begin
#RUN PARSER
#TOSS "GOOD" hashes to DB
#SEPARATE WINDOWS QUE
			
=end
		end
	end
	"Upload Complete"
end


=begin
	parserfile = File.open('johnfile.txt','w')
	parserfile << line
	parserfile.close
	test = %x[/Users/mubix/Desktop/imgs/tools/john/john ./johnfile.txt --show=LEFT --format=NT]
	if test == ""
		puts 'No NT Hash Found'
	else
		puts test 
	end
=end