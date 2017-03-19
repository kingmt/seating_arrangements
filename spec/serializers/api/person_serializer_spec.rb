require 'rails_helper'

describe Api::PersonSerializer do
  let(:table) { Table.create }
  let(:person) { create :person }

  it 'renders information for unseated person' do
    serializer = Api::PersonSerializer.new(person)
    expected = {"id" => person.id,
                "name" => person.name,
                "age" => person.age,
                "seated" => false,
                "seated_at_table" => nil}
    results = JSON.parse serializer.to_json
    expect(results).to eq expected
  end

  it 'renders information for seated person' do
    Seat.create table: table, person: person
    serializer = Api::PersonSerializer.new(person)
    expected = {"id" => person.id,
                "name" => person.name,
                "age" => person.age,
                "seated" => true,
                "seated_at_table" => table.id}
    results = JSON.parse serializer.to_json
    expect(results).to eq expected
  end
end

