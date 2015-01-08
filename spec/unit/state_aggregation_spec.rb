require 'rspec'
require 'pry'
require_relative '../../app/state_aggregation'

RSpec.describe StateAggregation do

  include StateAggregation

  let(:array) { [] }
  let(:array_of_arrays) { array << [] }

  let(:argument_with_data) do
    array << %w[timestamp checkid responsetime status]
    array << %w[1367849512 111, 76 UP]
    array << %w[1368514766 333 584 UP]
    array << %w[1367612872 111 0 DOWN]
  end

  let(:first_array) { %w[13676 DOWN] }
  let(:second_array) { %w[13678 UP] }
  let(:third_array) { %w[13679 UP] }
  let(:another_array) { %w[1368514766 UP] }

  let(:unsorted_data) do
    {
      111 => [second_array, third_array, first_array],
      333 => [another_array]
    }
  end

  let(:sorted_data) do
    {
      111 => [first_array, second_array, third_array],
      333 => [another_array]
    }
  end

  let(:sorted_data_with_unconfirmed) do
    {
      1234 => [%w[13676 UP], %w[13678 UNCONFIRMED_DOWN], %w[13860 UP], %w[13890 DOWN]]
    }
  end

  describe '#parse_raw_data' do

    it 'only accepts an array of arrays as argument' do
      expect { parse_raw_data(array_of_arrays) }.to_not raise_error
    end

    it 'does not accept an empty array' do
      expect { parse_raw_data(array) }.to raise_error(ArgumentError)
    end

    it 'does not accept a Hash' do
      expect { parse_raw_data({}) }.to raise_error(ArgumentError)
    end

    context 'with argument that does not contain any data' do

      it 'returns an empty Hash' do
        result = parse_raw_data(array_of_arrays)
        expect(result).to be_a(Hash)
        expect(result).to be_empty
      end
    end

    context 'with argument that contains data' do

      it 'returns a Hash with checkid as keys' do
        result = parse_raw_data(argument_with_data)
        expect(result).to be_a(Hash)
        expect(result.keys).to eq([argument_with_data[1][1].to_i, argument_with_data[2][1].to_i])
      end

      it 'returns a Hash with mappings to provided data' do
        first_data_row  = argument_with_data[1]
        second_data_row = argument_with_data[2]
        third_data_row  = argument_with_data[3]

        check_id_one = first_data_row[1].to_i
        check_id_two = second_data_row[1].to_i

        first_data  = first_data_row[0, 3]
        second_data = second_data_row[0, 3]
        third_data  = third_data_row[0, 3]

        expect(parse_raw_data(argument_with_data)).to eq(
                                                        check_id_one => [first_data, third_data],
                                                        check_id_two => [second_data]
                                                      )
      end
    end
  end

  describe '#sort_on_timestamps' do

    it 'returns a hash' do
      expect(sort_on_timestamp(unsorted_data)).to be_a(Hash)
    end

    it 'sorts arrays on timestamps in ascending order' do
      expect(sort_on_timestamp(unsorted_data)).to eq(sorted_data)
    end
  end

  describe '#aggregate_data' do

    it 'creates new instances of AggregatedStatus' do
      expect(AggregatedStatus).to receive(:new).exactly(3).times.and_return(AggregatedStatus.new)
      aggregate_data(sorted_data)
    end

    it 'returns an array of AggregatedStatus instances' do
      result = aggregate_data(sorted_data)
      expect(result[0]).to be_an(AggregatedStatus)
      expect(result[1]).to be_an(AggregatedStatus)
      expect(result[2]).to be_an(AggregatedStatus)
    end

    it 'returns the correct number of AggregatedStatus instances' do
      expect(aggregate_data(sorted_data).count).to be(3)
    end

    it 'does not record status UNCONFIRMED_DOWN' do
      AggregatedStatus.new(check_id: 1234, start_time: '13890', end_time: nil, status: 'DOWN')

      result = aggregate_data(sorted_data_with_unconfirmed)

      expect(result[0].check_id).to be(1234)
      expect(result[0].start_time).to eq('13676')
      expect(result[0].end_time).to eq('13890')
      expect(result[0].status).to eq('UP')

      expect(result[1].check_id).to be(1234)
      expect(result[1].start_time).to eq('13890')
      expect(result[1].end_time).to be_nil
      expect(result[1].status).to eq('DOWN')
    end
  end

  describe '#decide_end_time' do

    it 'returns a shifted array if status has changed with first element containing the end time' do
      expect(decide_end_time(sorted_data[111])).to eq([second_array, third_array])
    end

    it 'returns nil if status has not changed' do
      expect(decide_end_time([second_array, third_array])).to eq(nil)
    end
  end
end