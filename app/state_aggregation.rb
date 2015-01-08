require_relative 'aggregated_status'

module StateAggregation

  START_TIME = 0
  STATUS = 1
  UNCONFIRMED_DOWN = 'UNCONFIRMED_DOWN'

  def parse_raw_data(arr_of_arrs)
    raise ArgumentError unless arr_of_arrs.is_a?(Array)
    raise ArgumentError unless arr_of_arrs.first.is_a?(Array)

    # Slice off the first element since it contains the headers
    arr_of_arrs[1..-1].reduce({}) do |hash, arr|
      checkid       = arr[1].to_i
      hash[checkid] = [] unless hash[checkid]
      hash[checkid] << [arr[0], arr[3]]
      hash
    end
  end

  def sort_on_timestamp(hash)
    raise ArgumentError unless hash.is_a?(Hash)

    hash.each_value do |v|
      v.sort!
    end
  end

  def aggregate_data(hash)
    raise ArgumentError unless hash.is_a?(Hash)

    result = []

    key   = hash.keys.first
    value = hash[key] || []

    arr = value.first

    if arr
      aggregated_status = AggregatedStatus.new

      aggregated_status.check_id = key

      aggregated_status.start_time = arr[START_TIME]

      end_time = decide_end_time(value)

      aggregated_status.end_time = end_time.first.first if end_time && end_time.first

      aggregated_status.status = arr[STATUS]

      result << aggregated_status

      hash[key] = end_time

      hash.delete(key) if hash[key].nil? || hash[key].empty?
    end

    hash.empty? ? result : result + aggregate_data(hash)
  end

  def decide_end_time(arr_of_arrs)
    raise ArgumentError unless arr_of_arrs.is_a?(Array)
    raise ArgumentError unless arr_of_arrs[0].is_a?(Array)

    status = arr_of_arrs.shift[STATUS]
    arr_of_arrs.each_with_index do |array, index|
      unless status == array[STATUS] || array[STATUS] == UNCONFIRMED_DOWN
        return arr_of_arrs[index..-1]
      end
    end
    nil
  end

end