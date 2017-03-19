require 'rails_helper'

RSpec.describe Seat, type: :model do

  context 'without a person' do
    let(:seat) { Seat.new }

    it 'delegates the name' do
      expect(seat.name).to eq nil
    end

    it 'delegates the age' do
      expect(seat.age).to eq nil
    end
  end

  context 'with a person' do
    let(:person) { create :person }
    let(:seat) { Seat.new person: person }

    it 'delegates the name' do
      expect(seat.name).to eq person.name
    end

    it 'delegates the age' do
      expect(seat.age).to eq person.age
    end
  end


end
