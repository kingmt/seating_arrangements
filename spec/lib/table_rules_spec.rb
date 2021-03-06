require 'rails_helper'

RSpec.describe TableRules do
  let(:table) { Table.create }

  let(:sam)     { Person.create name: 'Sam',     age: 22 }
  let(:john)    { Person.create name: 'John',    age: 30 }
  let(:chris)   { Person.create name: 'Chris',   age: 21 }
  let(:matt)    { Person.create name: 'Matt',    age: 25 }
  let(:michael) { Person.create name: 'Michael', age: 19 }
  let(:sara)    { Person.create name: 'Sara',    age: 19 }

  let(:sam_seat)     { Seat.create person: sam,     table: table }
  let(:john_seat)    { Seat.create person: john,    table: table }
  let(:chris_seat)   { Seat.create person: chris,   table: table }
  let(:matt_seat)    { Seat.create person: matt,    table: table }
  let(:michael_seat) { Seat.create person: michael, table: table }
  let(:sara_seat)    { Seat.create person: sara,    table: table }

  describe 'check_table' do
    context 'returns empty errors' do
      it 'for single seat' do
        seats = [michael_seat]
        expected = []
        result = TableRules.check_table seats
        expect(result).to eq expected
      end

      it 'for 2 seats' do
        seats = [michael_seat, sara_seat]
        expected = []
        result = TableRules.check_table seats
        expect(result).to eq expected
      end

      it 'for more seats' do
        seats = [michael_seat, sara_seat, sam_seat, chris_seat]
        expected = []
        result = TableRules.check_table seats
        expect(result).to eq expected
      end
    end

    it 'returns 1 error' do
      seats = [michael_seat, sam_seat, matt_seat, chris_seat]
      expected = ["Michael is younger than both Chris and Sam"]
      result = TableRules.check_table seats
      expect(result).to eq expected
    end

    it 'returns a mess of errors' do
      seats = [michael_seat, sam_seat, sara_seat, john_seat, chris_seat]
      expected = ["Michael is younger than both Chris and Sam",
                  "The age difference between John and Sara is greater than 5",
                  "Sara is younger than both Sam and John",
                  "The age difference between Sara and John is greater than 5",
                  "The age difference between Chris and John is greater than 5",
                  "The age difference between John and Chris is greater than 5"
                 ]
      result = TableRules.check_table seats
      # Have to break all the checks apart since rspec is abreviating the diff
      expect(result.size).to eq expected.size
      expect(result[0]).to eq expected[0]
      expect(result[1]).to eq expected[1]
      expect(result[2]).to eq expected[2]
      expect(result[3]).to eq expected[3]
      expect(result[4]).to eq expected[4]
      expect(result[5]).to eq expected[5]
    end
  end

  describe 'move!' do
    it 'moves Sam from the front to between Sara and Chris' do
      seats = [sam_seat, michael_seat, sara_seat, chris_seat]
      result = TableRules.move! seats, sam_seat, 3
      # need to match internals since any new seat object created
      # here won't be the same seat object created in place!
      result_names = result.collect(&:name)
      expect(result_names).to eq %w( Michael Sara Sam Chris)
    end

    it 'cannot move Sam to between Michael and Sara' do
      seats = [sam_seat, michael_seat, sara_seat, chris_seat]
      result = TableRules.move! seats, sam_seat, 2
      expect(result).to eq nil
    end
  end

  describe 'place!' do
    it 'places Sam at the front' do
      seats = [michael_seat, sara_seat, chris_seat]
      new_seat = Seat.new table: table, person: sam
      TableRules.place! seats, new_seat, 1
      table.reload
      # matching names
      result_names = table.seats.collect(&:name)
      expect(result_names).to eq %w( Sam Michael Sara Chris)
    end

    it 'places Sam between Sara and Chris' do
      seats = [michael_seat, sara_seat, chris_seat]
      new_seat = Seat.new table: table, person: sam
      TableRules.place! seats, new_seat, 3
      table.reload
      # matching names
      result_names = table.seats.collect(&:name)
      expect(result_names).to eq %w( Michael Sara Sam Chris)
    end

    it 'cannot place Sam between Michael and Sara' do
      seats = [michael_seat, sara_seat, chris_seat]
      new_seat = Seat.new table: table, person: sam
      result = TableRules.place! seats, new_seat, 2
      expect(result).to eq nil
    end

  end

  describe 'autoplace!' do
    it 'places Sam at the front' do
      seats = [michael_seat, sara_seat, chris_seat]
      TableRules.autoplace! seats, sam
      table.reload
      # matching names
      result_names = table.seats.collect(&:name)
      expect(result_names).to eq %w( Sam Michael Sara Chris)
    end

    it 'places Matt in the middle' do
      seats = [michael_seat, sara_seat, sam_seat, chris_seat]
      expect(TableRules.autoplace! seats, matt).to eq true
      table.reload
      # matching names
      result_names = table.seats.collect(&:name)
      expect(result_names).to eq %w( Michael Sara Sam Matt Chris)
    end

    it 'cannot place John' do
      seats = [michael_seat, sara_seat, chris_seat]
      result = TableRules.autoplace! seats, john
      expect(result).to eq nil
    end
  end

  describe 'can_be_unseated' do
    context 'returns true' do
      it 'has one seat' do
        seats = [sam_seat]
        result = TableRules.can_be_unseated seats, sam_seat
        expect(result).to eq true
      end

      it 'has two seats' do
        seats = [sam_seat, chris_seat]
        result = TableRules.can_be_unseated seats, sam_seat
        expect(result).to eq true
      end

      it 'many seats' do
        seats = [michael_seat, sara_seat, sam_seat, chris_seat]
        result = TableRules.can_be_unseated seats, sam_seat
        expect(result).to eq true
      end
    end

    it 'returns false' do
      seats = [michael_seat, sara_seat, sam_seat, chris_seat]
      result = TableRules.can_be_unseated seats, sara_seat
      expect(result).to eq false
    end
  end
end
