require 'csv'

class StateAggregation

  def parse_raw_data(arr_of_arrs)

  end

end

if ARGV[0]
  filename = ARGV[0].chomp
  if File.exist?(filename)
    state_aggregation = StateAggregation.new
    state_aggregation.parse_raw_data(CSV.read(filename))
  else
    puts 'File cannot be found'
  end
else
  puts 'Usage: ruby state_aggregation.rb <filename>'
end