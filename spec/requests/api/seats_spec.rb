require 'rails_helper'

describe 'Seats API' do
  let!(:table) { Table.create }
  let!(:sam)     { Person.create name: 'Sam',     age: 22 }
  let!(:john)    { Person.create name: 'John',    age: 30 }
  let!(:chris)   { Person.create name: 'Chris',   age: 21 }
  let!(:matt)    { Person.create name: 'Matt',    age: 25 }
  let!(:michael) { Person.create name: 'Michael', age: 19 }
  let!(:sara)    { Person.create name: 'Sara',    age: 19 }
  let!(:jenny)   { Person.create name: 'Jenny',   age: 23 }

  it 'returns 404 if table doesnt exist' do
      post "/api/tables/99/seats"
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq "Table does not exist"
  end

  describe 'POST /api/table/:table_id/seats' do
    it 'returns error if person already seated' do
      Seat.create table: table, person: john
      post "/api/tables/#{table.id}/seats", params: {person_id: john.id}
      json = JSON.parse response.body
      expect(response.status).to eq 422
      expect(json['errors']).to eq 'Person is already seated'
    end

    it 'returns error if person does not exist' do
      post "/api/tables/#{table.id}/seats", params: {person_id: 99}
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq 'Person does not exist'
    end

    context 'autoplace' do
      let!(:seat1) { Seat.create person: michael, table: table }
      let!(:seat2) { Seat.create person: sara,    table: table }
      let!(:seat3) { Seat.create person: sam,     table: table }
      let!(:seat4) { Seat.create person: chris,   table: table }

      it 'places Matt between Sam and Chris' do
        post "/api/tables/#{table.id}/seats", params: {person_id: matt.id}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        # this verification is a little bit harder
        # need to verify that Matt was placed between Sam and Chris
        # but I don't want to make the test break when
        # table serialization is changed
        result_names = json['seats'].collect{|s| s['name']}
        expect(result_names).to eq %w( Michael Sara Sam Matt Chris)
      end

      it 'cannot place John' do
        post "/api/tables/#{table.id}/seats", params: {person_id: john.id}
        json = JSON.parse response.body
        expect(response.status).to eq 422
        expect(json['errors']).to eq 'Person cannot be seated'
      end
    end

  # let!(:sam)     { Person.create name: 'Sam',     age: 22 }
  # let!(:john)    { Person.create name: 'John',    age: 30 }
  # let!(:chris)   { Person.create name: 'Chris',   age: 21 }
  # let!(:matt)    { Person.create name: 'Matt',    age: 25 }
  # let!(:michael) { Person.create name: 'Michael', age: 19 }
  # let!(:sara)    { Person.create name: 'Sara',    age: 19 }
    #                                    'Jenny',   age: 23
  # Seat.create person: sam,     table: table
  # Seat.create person: john,    table: table
  # Seat.create person: chris,   table: table
  # Seat.create person: matt,    table: table
  # Seat.create person: michael, table: table
  # Seat.create person: sara,    table: table
  # Seat.create person: jenny,   table: table
    context 'place at a specific position' do
      let!(:seat1) { Seat.create person: michael, table: table }
      let!(:seat2) { Seat.create person: sara,    table: table }
      let!(:seat3) { Seat.create person: sam,     table: table }
      let!(:seat4) { Seat.create person: chris,   table: table }

      it 'can place Jenny between Sara and Sam' do
        post "/api/tables/#{table.id}/seats",
             params: {person_id: jenny.id, position: 3}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        # this verification is a little bit harder
        # need to verify that Jenny was placed between Sara and Sam
        # but I don't want to make the test break when
        # table serialization is changed
        result_names = json['seats'].collect{|s| s['name']}
        expect(result_names).to eq %w( Michael Sara Jenny Sam Chris)
      end

      it 'cannot place Jenny between Chris and Michael' do
        post "/api/tables/#{table.id}/seats",
             params: {person_id: jenny.id, position: 5}
        json = JSON.parse response.body
        expect(response.status).to eq 422
        expect(json['errors']).to eq 'Person cannot be seated at that position'
      end
    end
  end

  describe 'PUT /api/table/:table_id/seats/:id' do
    let!(:seat1) { Seat.create person: michael, table: table }
    let!(:seat2) { Seat.create person: sara,    table: table }
    let!(:seat3) { Seat.create person: jenny,   table: table }
    let!(:seat4) { Seat.create person: sam,     table: table }
    let!(:seat5) { Seat.create person: chris,   table: table }

    it 'returns an error is position is not given' do
      put "/api/tables/#{table.id}/seats/#{seat1.id}"
      json = JSON.parse response.body
      expect(response.status).to eq 422
      expect(json['errors']).to eq 'Position is required'
    end

    it 'returns error is seat does not exist' do
      put "/api/tables/#{table.id}/seats/99",
          params: {position: 5}
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq 'Seat does not exist'
    end

    it 'can move' do
      put "/api/tables/#{table.id}/seats/#{seat3.id}",
          params: {position: 4}
      json = JSON.parse response.body
      # this verification is a little bit harder
      # need to verify that Jenny was placed between Sara and Sam
      # but I don't want to make the test break when
      # table serialization is changed
      result_names = json['seats'].collect{|s| s['name']}
      expect(result_names).to eq %w( Michael Sara Sam Jenny Chris)
    end

    it 'cannot move' do
      put "/api/tables/#{table.id}/seats/#{seat3.id}",
          params: {position: 5}
      json = JSON.parse response.body
      expect(response.status).to eq 422
      expect(json['errors']).to eq 'Person cannot be seated at that position'
    end
  end

  describe 'DELETE /api/table/:table_id/seats/:id' do
    let!(:seat1) { Seat.create person: michael, table: table }
    let!(:seat2) { Seat.create person: sara,    table: table }
    let!(:seat3) { Seat.create person: sam,     table: table }
    let!(:seat4) { Seat.create person: chris,   table: table }

    it 'returns error is seat does not exist' do
      delete "/api/tables/#{table.id}/seats/99"
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq 'Seat does not exist'
    end

    it 'returns error if the seat cannot be deleted due to invalid table' do
      delete "/api/tables/#{table.id}/seats/#{seat2.id}"
      json = JSON.parse response.body
      expect(response.status).to eq 422
      expect(json['errors']).to eq "Cannot remove the seat, the table would be invalid"
    end

    it 'removes the seat' do
      delete "/api/tables/#{table.id}/seats/#{seat3.id}"
      json = JSON.parse response.body
      expect(response.status).to eq 200
      # this verification is a little bit harder
      # need to verify that Matt was placed between Sam and Chris
      # but I don't want to make the test break when
      # table serialization is changed
      result_names = json['seats'].collect{|s| s['name']}
      expect(result_names).to eq %w( Michael Sara Chris)
    end
  end
end
