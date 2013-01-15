#!/usr/bin/env ruby
require	'rubygems'
require 'sinatra'
require 'tire'
require 'rex'
require 'fifo'

CRYPT = Rex::Proto::NTLM::Crypt


configure do
	set :public_folder, Proc.new { File.join(root, "static") }
	set :per_page, 25
end

def generate_hashes(password)

	lm = CRYPT.lm_hash(password).unpack("H*")[0]
	return lm
end

helpers do
	Tire.configure do
		elasurl = File.open("elastic.conf").first
		url("#{elasurl.chomp}/")
	end

	Tire.index 'connectivitytest' do
		delete
		create
		store :title => 'One',   :tags => ['ruby'],           :published_on => '2011-01-01'
		store :title => 'Two',   :tags => ['ruby', 'python'], :published_on => '2011-01-02'
		delete
	end
=begin
	Tire.index 'whitechapel-hashes' do

		# REMOVE THIS DELETE
		delete

		create :mappings => {
			:document => {
			  :properties => {
					:password  => { :type => 'string', :index => 'not_analyzed', :include_in_all => false },
					:hash      => { :type => 'string', :analyzer => 'snowball'  },
					:type     => { :type => 'string'}
				}
			}
		}
		hashforhell = generate_hashes('hello world')
		document = [
			{:password => 'hello world', :hash => '5eb63bbbe01eeed093cb22bb8f5acdc3', :hashtype => 'md5', :type => 'document'},
			{:password => 'hello world', :hash => "#{hashforhell}", :hashtype => 'lm', :type => 'document'},
			{:password => 'password', :hash => '5f4dcc3b5aa765d61d8327deb882cf99', :hashtype => 'md5', :type => 'document'}
		]

		import document
	end
=end
end

get '/' do
	# puts @s.to_curl

	erb :index
end

get '/search/pass' do
	q = params[:q].to_s !~ /\S/ ? '*' : params[:q].to_s
	f = params[:p].to_i*settings.per_page

	pipe = Fifo.new('que.fifo', :w, :nowait)
	puts q
	pipe.puts "#{q}"

	@s = Tire.search( 'whitechapel-hashes' ) do |search|
		search.query { |query| query.string "password:\"#{q}\"" }
		search.size settings.per_page
		search.from f
	end

	erb :search
end

get '/search/hash' do
	h = params[:h].to_s !~ /\S/ ? '*' : params[:h].to_s
	f = params[:p].to_i*settings.per_page

	@s = Tire.search( 'whitechapel-hashes' ) do |search|
		search.query { |query| query.string "hash:#{h}" }
		search.size settings.per_page
		search.from f
	end

	erb :search
end

# Handle GET-request (Show the upload form)
get "/upload" do
  erb :upload
end

post "/upload/dictionary" do
	File.open('uploads/' + params['myfile'][:filename], "w") do |f|
		f.write(params['myfile'][:tempfile].read)
	end
	return "The file was successfully uploaded!"
end

# Handle POST-request (Receive and save the uploaded file)
post "/upload/pwdump" do
=begin
	File.open('uploads/' + params['myfile'][:filename], "w") do |f|
		f.write(params['myfile'][:tempfile].read)
	end
=end
	@tempfile = params['pwdump'][:tempfile].read
	erb :uploadprocessing
end

post "/upload/shadowfile" do
	File.open('uploads/' + params['myfile'][:filename], "w") do |f|
		f.write(params['myfile'][:tempfile].read)
	end
	return "The file was successfully uploaded!"
end







# john ./johnfile.txt --show=LEFT --format=NT