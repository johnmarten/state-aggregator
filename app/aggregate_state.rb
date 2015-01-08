require 'csv'
require_relative 'state_aggregation'

include StateAggregation

if ARGV[0]
  filename = ARGV[0].chomp
  if File.exist?(filename)
    hash = sort_on_timestamp(parse_raw_data(CSV.read(filename)))
    result = aggregate_data(hash)
    CSV.open('aggregated.csv', 'wb') do |csv|
      csv << ['Checkid', 'Start time', 'End time', 'Status']
      result.each do |row|
        csv << [row.check_id, row.start_time, row.end_time, row.status]
      end
    end
  else
    puts 'File cannot be found'
  end
else
  puts 'Usage: ruby state_aggregation.rb <filename>'
end