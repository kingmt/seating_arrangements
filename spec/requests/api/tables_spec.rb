require 'rails_helper'

describe 'Tables API' do
  context 'table not found' do
    it 'on show' do
      get '/api/tables/99'
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq 'Table does not exist'
    end

    it 'on update' do
      get '/api/tables/99'
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq 'Table does not exist'
    end

    it 'on destroy' do
      get '/api/tables/99'
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq 'Table does not exist'
    end
  end

  it 'fetches index' do
    Table.create
    Table.create
    get '/api/tables'
    json = JSON.parse response.body
    expect(response.status).to eq 200
    # not testing the contents table serialization here
    # that belongs to the serializer tests, just making
    # sure we got 2 tables like expected
    expect(json.size).to eq 2
  end

  it 'creates new table' do
    expect {
      post '/api/tables'
    }.to change{Table.count}.by 1
    json = JSON.parse response.body
    expect(response.status).to eq 200
    # double checking that the last table created was the one returned
    table = Table.last
    expect(json['id'].to_i).to eq table.id
  end

  it 'shows table' do
    Table.create
    table = Table.create
    Table.create
    get "/api/tables/#{table.id}"
    json = JSON.parse response.body
    expect(response.status).to eq 200
    # double checking that the right table was fetched
    expect(json['id'].to_i).to eq table.id
  end

  describe 'bulk update a table' do
    let!(:table)  { Table.create }
    let!(:table2) { Table.create }
    let!(:sam)     { Person.create name: 'Sam',     age: 22 }
    let!(:chris)   { Person.create name: 'Chris',   age: 21 }
    let!(:michael) { Person.create name: 'Michael', age: 19 }
    let!(:sara)    { Person.create name: 'Sara',    age: 19 }
    let!(:john)    { Person.create name: 'John',    age: 30 }

    context 'errors' do
      it 'when people param is missing' do
        put "/api/tables/#{table.id}"
        json = JSON.parse response.body
        expect(response.status).to eq 422
        expect(json['errors']).to eq 'Invalid parameters'
      end

      it 'when people param is not a list' do
        put "/api/tables/#{table.id}",
            params: {people: 1}
        json = JSON.parse response.body
        expect(response.status).to eq 422
        expect(json['errors']).to eq 'Invalid parameters'
      end

      it 'when there is a non-existant person' do
        put "/api/tables/#{table.id}",
            params: {people: [99, 100]}
        json = JSON.parse response.body
        expect(response.status).to eq 422
        expect(json['errors']).to eq 'Non-existant people sent'
      end

      context 'people seated at other tables' do
        it 'one' do
          seat = Seat.create table: table2, person: sara
          put "/api/tables/#{table.id}",
              params: {people: [michael.id, sara.id, sam.id, chris.id]}
          json = JSON.parse response.body
          expect(response.status).to eq 422
          expect(json['errors']).to eq 'Sara has already been seated at another table'
        end

        it '2' do
          seat = Seat.create table: table2, person: sara
          seat = Seat.create table: table2, person: sam
          put "/api/tables/#{table.id}",
              params: {people: [michael.id, sara.id, sam.id, chris.id]}
          json = JSON.parse response.body
          expect(response.status).to eq 422
          expect(json['errors']).to eq 'Sam and Sara have already been seated at another table'
        end

        it '3' do
          seat = Seat.create table: table2, person: sara
          seat = Seat.create table: table2, person: sam
          seat = Seat.create table: table2, person: michael
          put "/api/tables/#{table.id}",
              params: {people: [michael.id, sara.id, sam.id, chris.id]}
          json = JSON.parse response.body
          expect(response.status).to eq 422
          expect(json['errors']).to eq 'Michael, Sam, and Sara have already been seated at another table'
        end
      end

      it 'when it would result in an invalid table' do
        put "/api/tables/#{table.id}",
            params: {people: [michael.id, sara.id, john.id, chris.id]}
        json = JSON.parse response.body
        expect(response.status).to eq 422
        expect(json['errors']).to eq "Unable to seat those people in that order"
      end
    end

    context 'success' do
      it 'when table was empty' do
        put "/api/tables/#{table.id}",
            params: {people: [michael.id, sara.id, sam.id, chris.id]}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        # this verification is a little bit harder
        # need to verify that Jenny was placed between Sara and Sam
        # but I don't want to make the test break when
        # table serialization is changed
        result_names = json['seats'].collect{|s| s['name']}
        expect(result_names).to eq %w( Michael Sara Sam Chris)
      end

      it 'when table had previous seats' do
        seat = Seat.create table: table, person: sara
        seat = Seat.create table: table, person: michael
        put "/api/tables/#{table.id}",
            params: {people: [michael.id, sara.id, sam.id, chris.id]}
        json = JSON.parse response.body
        expect(response.status).to eq 200
        # this verification is a little bit harder
        # need to verify that Jenny was placed between Sara and Sam
        # but I don't want to make the test break when
        # table serialization is changed
        result_names = json['seats'].collect{|s| s['name']}
        expect(result_names).to eq %w( Michael Sara Sam Chris)
      end
    end
  end

  describe 'destroy' do
    it 'empty table' do
      table = Table.create
      expect {
        delete "/api/tables/#{table.id}"
      }.to change{Table.count}.by -1
      json = JSON.parse response.body
      expect(response.status).to eq 200
    end

    it 'with people' do
      table = Table.create
      p1 = create :person
      seat1 = Seat.create table: table, person: p1
      p2 = create :person
      seat2 = Seat.create table: table, person: p2
      expect {
        expect {
          delete "/api/tables/#{table.id}"
        }.to change{Table.count}.by -1
      }.to change{Seat.count}.by -2
      json = JSON.parse response.body
      expect(response.status).to eq 200
    end
  end
end
