require 'rails_helper'

describe Api::TableSerializer do
  let!(:table) { Table.create }
  let!(:person1) { create :person, name: 'Matt', age: 20 }
  let!(:person2) { create :person, name: 'John', age: 20 }
  let!(:person3) { create :person, name: 'Paul', age: 22 }
  let!(:seat1) { Seat.create table: table, person: person1 }
  let!(:seat2) { Seat.create table: table, person: person2 }
  let!(:seat3) { Seat.create table: table, person: person3 }

  it 'renders information' do
    table.reload
    serializer = Api::TableSerializer.new(table)
    expected = {"id" => table.id,
                "seats" => [{"id" => 1, "name" => "Matt", "age" => 20, "can_be_unseated" => false},
                            {"id" => 2, "name" => "John", "age" => 20, "can_be_unseated" => false},
                            {"id" => 3, "name" => "Paul", "age" => 22, "can_be_unseated" => true }]
               }
    results = JSON.parse serializer.to_json
    expect(results).to eq expected
  end
end

