require 'rails_helper'

describe 'People API' do
  context 'person not found' do
    it 'on show' do
      get '/api/people/99'
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq 'Person does not exist'
    end

    it 'on update' do
      get '/api/people/99'
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq 'Person does not exist'
    end

    it 'on destroy' do
      get '/api/people/99'
      json = JSON.parse response.body
      expect(response.status).to eq 404
      expect(json['errors']).to eq 'Person does not exist'
    end
  end

  it 'fetches index' do
    create :person
    create :person
    get '/api/people'
    json = JSON.parse response.body
    expect(response.status).to eq 200
    # not testing the contents person serialization here
    # that belongs to the serializer tests, just making
    # sure we got 2 people like expected
    expect(json.size).to eq 2
  end

  it 'creates new person' do
    expect {
      post '/api/people', params: {person: {name: "Joe", age: 25}}
    }.to change{Person.count}.by 1
    json = JSON.parse response.body
    expect(response.status).to eq 200
    # double checking that the last person created was the one returned
    person = Person.last
    expect(json['id'].to_i).to eq person.id
  end

  it 'shows person' do
    create :person
    person = create :person
    create :person
    get "/api/people/#{person.id}"
    json = JSON.parse response.body
    expect(response.status).to eq 200
    # double checking that the right person was fetched
    expect(json['id'].to_i).to eq person.id
  end

  describe 'update' do
    it 'unseated person sucessfully' do
      person = create :person, age: 22
      put "/api/people/#{person.id}", params: {person: {age: 23}}
      person.reload
      expect(response.status).to eq 200
      expect(person.age).to eq 23
    end

    it 'seated person fails' do
      table = Table.create
      person = create :person, age: 22
      seat = Seat.create person: person, table: table
      put "/api/people/#{person.id}", params: {person: {age: 23}}
      person.reload
      expect(response.status).to eq 422
      expect(person.age).to eq 22
      json = JSON.parse response.body
      expect(json['errors']).to eq 'Cannot update a seated person'
    end
  end

  describe 'destroy' do
    it 'unseated person' do
      person = create :person
      expect {
        delete "/api/people/#{person.id}"
      }.to change{Person.count}.by -1
      json = JSON.parse response.body
      expect(response.status).to eq 200
    end

    it 'fails on seated person' do
      person = create :person
      table = Table.create
      seat = Seat.create person: person, table: table
      expect {
        delete "/api/people/#{person.id}"
      }.to change{Person.count}.by 0
      json = JSON.parse response.body
      expect(response.status).to eq 422
      expect(json['errors']).to eq 'Cannot delete a seated person'
    end
  end
end

