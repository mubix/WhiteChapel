#!/usr/bin/env ruby

require 'fifo'
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

def check_unique_and_store(password,hash,hashtype)
	check = Tire.search 'whitechapel-hashes' do |search|
		search.query { |query| query.string "password:\"#{password}\""}
	end
	check.filter :terms, :hashtype => ["#{hashtype}"]

	if check.results.total > 0 then
		return
	else
		store :password => password, :hash => hash, :hashtype => hashtype, :type => 'document'
	end
end

def check_pass(password)
	check = Tire.search 'whitechapel-hashes' do |search|
		search.query { |query| query.string "password:\"#{password}\""}
	end
	if check.results.total > 0 then
		return true
	end
end

def hash_mysql_password pass
  "*" + Digest::SHA1.hexdigest(Digest::SHA1.digest(pass)).upcase
end

loop do
	pipe = Fifo.new('que.fifo')
	line = pipe.readline
	pass = line.chomp
	if check_pass(pass)
		puts "Skipping #{pass} - already in db"
		next
	end
	puts pass
	lm = CRYPT.lm_hash(pass[0..13]).unpack("H*").join
	ntlm = CRYPT.ntlm_hash(pass).unpack("H*")[0]
	md5 = Digest::MD5.hexdigest(pass)
	sha1 = Digest::SHA1.hexdigest(pass)
	sha256 = Digest::SHA256.hexdigest(pass)
	sha512 = Digest::SHA512.hexdigest(pass)
	mysql = hash_mysql_password(pass)

	puts "LM: #{lm}"
	puts "NTLM: #{ntlm}"
	puts "MD5: #{md5}"
	puts "SHA1: #{sha1}"
	puts "SHA256: #{sha256}"
	puts "SHA512: #{sha512}"
	puts "MYSQL: #{mysql}"


	Tire.index 'whitechapel-hashes' do
		check_unique_and_store(pass, lm, 'lm')
		check_unique_and_store(pass, ntlm, 'ntlm')
		check_unique_and_store(pass, md5, 'md5')
		check_unique_and_store(pass, sha1, 'sha1')
		check_unique_and_store(pass, sha256, 'sha256')
		check_unique_and_store(pass, sha512, 'sha512')
		check_unique_and_store(pass, mysql, 'mysql')
	end
end
