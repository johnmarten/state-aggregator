require 'csv'
require_relative 'state_aggregation'

include StateAggregation

if ARGV[0]
  filename = ARGV[0].chomp
  if File.exist?(filename)
    parse_raw_data(CSV.read(filename))
  else
    puts 'File cannot be found'
  end
else
  puts 'Usage: ruby state_aggregation.rb <filename>'
end