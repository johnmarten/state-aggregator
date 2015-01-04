module StateAggregation

  def self.parse_raw_data(arr_of_arrs)
    raise ArgumentError unless arr_of_arrs.is_a?(Array)
    raise ArgumentError unless arr_of_arrs[0].is_a?(Array)

    # Slice off the first element since it should contain the headers
    arr_of_arrs[1..-1].reduce({}) do |hash, arr|
      checkid = arr[1].to_i
      hash[checkid] = [] unless hash[checkid]
      hash[checkid] << arr[0, 3]
      hash
    end
  end
end