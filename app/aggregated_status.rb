class AggregatedStatus
  attr_accessor :check_id, :start_time, :end_time, :status

  def initialize(options = {})
    @check_id = options[:check_id]
    @start_time = options[:start_time]
    @end_time = options[:end_time]
    @status = options[:status]
  end
end