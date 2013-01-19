#!/usr/bin/env ruby

require	'rubygems'
require 'resque'
require './importer'

count = 0
File.readlines("#{ARGV[0]}").each do |line|
	Resque.enqueue(EnqueuePasswords, line.chomp)
	count += 1
end
puts "Imported #{count} lines"
