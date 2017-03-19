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
