require 'rspec'
require_relative '../../app/state_aggregation'

RSpec.describe StateAggregation do

  describe '#StateAggregation.parse_raw_data' do

    let(:array) { [] }
    let(:array_of_arrays) { array << [] }
    let(:argument_with_data) do
      array << %w[timestamp checkid responsetime status]
      array << %w[1367849512, 111, 76, UP]
      array << %w[1368514766, 333, 584, UP]
      array << %w[1367612872, 111, 0, UNCONFIRMED_DOWN]
    end

    it 'only accepts an array of arrays as argument' do
      expect { subject.parse_raw_data(array_of_arrays) }.to_not raise_error
    end

    it 'does not accept an empty array' do
      expect { subject.parse_raw_data(array) }.to raise_error(ArgumentError)
    end

    it 'does not accept a Hash' do
      expect { subject.parse_raw_data({}) }.to raise_error(ArgumentError)
    end

    context 'with argument that does not contain any data' do

      it 'returns an empty Hash' do
        result = subject.parse_raw_data(array_of_arrays)
        expect(result).to be_a(Hash)
        expect(result).to be_empty
      end
    end

    context 'with argument that contains data' do

      it 'returns a Hash with checkid as keys' do
        result = subject.parse_raw_data(argument_with_data)
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

        expect(subject.parse_raw_data(argument_with_data)).to eq(
                                                                check_id_one => [first_data, third_data],
                                                                check_id_two => [second_data]
                                                              )
      end
    end
  end
end