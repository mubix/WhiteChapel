#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

require 'rex'
require 'tire'
require 'rex/proto/ntlm/crypt'
require 'digest/sha1'
require 'digest/md5'
CRYPT = Rex::Proto::NTLM::Crypt


Tire.configure do
	elasurl = File.open("elastic.conf").first || 'http://127.0.0.1:9200'
	url("#{elasurl.chomp}/")
end

def check_unique(hashhash)
=begin
	check = Tire.search 'whitechapel-hashes' do
		query do
			string "password:\"#{hashhash[:password]}\""
		end
		filter :terms, :hashtype => ["#{hashhash[:hashtype]}"]
	end

	if check.results.total > 0 then
		return
	else
=end
		return hashhash
	#end
end

def check_pass(password)
	check = Tire.search 'whitechapel-hashes' do
		query do
			string "password:\"#{password}\""
		end
	end
	if check.results.total > 0 then
		return true
	end
end

def hash_mysql_password pass
  "*" + Digest::SHA1.hexdigest(Digest::SHA1.digest(pass)).upcase
end

def generate_hashes(pass)
	hashes = {}

	#LM
	lm = CRYPT.lm_hash(pass[0..13]).unpack("H*").join
	hashes['lm'] = {:password => pass, :hash => lm, :hashtype => 'lm', :type => 'document'}

	#NTLM
	ntlm = CRYPT.ntlm_hash(pass).unpack("H*")[0]
	hashes['ntlm'] = {:password => pass, :hash => ntlm, :hashtype => 'ntlm', :type => 'document'}

	#NetNTLMv1 w/ static challenge of 1122334455667788
	ntlmv1 = CRYPT.ntlm_response(:ntlm_hash => [ntlm].pack("H*"), :challenge => ['1122334455667788'].pack("H*")).unpack("H*")[0]
	hashes['ntlmv1'] = {:password => pass, :hash => ntlmv1, :hashtype => 'ntlmv1', :type => 'document'}

	#MD5
	md5 = Digest::MD5.hexdigest(pass)
	hashes['md5'] = {:password => pass, :hash => md5, :hashtype => 'md5', :type => 'document'}

	#SHA1
	sha1 = Digest::SHA1.hexdigest(pass)
	hashes['sha1'] = {:password => pass, :hash => sha1, :hashtype => 'sha1', :type => 'document'}

	#SHA256
	sha256 = Digest::SHA256.hexdigest(pass)
	hashes['sha256'] = {:password => pass, :hash => sha256, :hashtype => 'sha256', :type => 'document'}

	#SHA512
	sha512 = Digest::SHA512.hexdigest(pass)
	hashes['sha512'] = {:password => pass, :hash => sha512, :hashtype => 'sha512', :type => 'document'}

	#MySQL
	mysql = hash_mysql_password(pass)
	hashes['mysql'] = {:password => pass, :hash => mysql, :hashtype => 'mysql', :type => 'document'}

	return hashes
end


# Resque queueing code
module EnqueuePasswords

	@queue = :passque

	def self.perform(pass)
		puts "Processing #{pass}"

		if check_pass(pass)
			puts 'Password already in DB'
			return
		else
			puts 'Password no yet in DB'
		end

		Tire.index 'whitechapel-hashes' do
			@inputone = []
			hashes = {}
			hashes = generate_hashes(pass)
			hashes.each do |type,hashhash|
				@inputone << check_unique(hashhash)
			end
			@inputone.compact!
			import @inputone
		end
	end
end

module EnqueueBulk
	@queue = :bulkque

	def self.perform(passlist)
		bulkimport = []
		puts "Bulk Processing Job"
		passlist.each do |pass|

			if check_pass(pass)
				next
			end
			hashes = {}
			hashes = generate_hashes(pass)
			hashes.each do |type,hashhash|
				bulkimport << check_unique(hashhash)
			end
		end
		bulkimport.compact!
		Tire.index 'whitechapel-hashes' do
			import bulkimport
		end
	end
end
