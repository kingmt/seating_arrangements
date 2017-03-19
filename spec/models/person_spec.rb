require 'rails_helper'

RSpec.describe Person, type: :model do
  let(:person) { create :person }
  let(:table) { Table.create }

  describe 'seated' do
    it 'returns false' do
      expect(person.seated).to eq false
    end

    it 'returns true' do
      Seat.create table: table, person: person
      expect(person.seated).to eq true
    end
  end

  describe 'seated_at_table' do
    it 'returns nil' do
      expect(person.seated_at_table).to eq nil
    end

    it 'returns table number' do
      Seat.create table: table, person: person
      expect(person.seated_at_table).to eq table.id
    end
  end
end
