#!/usr/bin/env ruby

require	'rubygems'
require 'resque'
require './importer'

count = 0
counter = 0
queue = []
File.readlines("#{ARGV[0]}").each do |line|
	queue << "#{line.chomp.force_encoding('UTF-8')}"
	if counter == 10000 then
		Resque.enqueue(EnqueueBulk, queue)
		counter = 0
		queue = []
	end
	counter += 1
	count += 1
end
if queue.any?
	Resque.enqueue(EnqueueBulk, queue)
end
puts "Imported #{count} lines"
