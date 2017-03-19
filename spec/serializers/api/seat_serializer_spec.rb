require 'rails_helper'

describe Api::SeatSerializer do
  let(:table) { Table.create }
  let(:person) { create :person }
  let(:seat) { Seat.create table: table, person: person }

  it 'renders information' do
    serializer = Api::SeatSerializer.new(seat)
    expected = {"id" => seat.id,
                "name" => person.name,
                "age" => person.age,
                "can_be_unseated" => true}
    results = JSON.parse serializer.to_json
    expect(results).to eq expected
  end
end
