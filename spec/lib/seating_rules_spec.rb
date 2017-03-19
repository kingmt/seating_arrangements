require 'rails_helper'

RSpec.describe SeatingRules do
  let(:sam)     { Person.new name: 'Sam',     age: 22 }
  let(:john)    { Person.new name: 'John',    age: 30 }
  let(:chris)   { Person.new name: 'Chris',   age: 21 }
  let(:matt)    { Person.new name: 'Matt',    age: 25 }
  let(:michael) { Person.new name: 'Michael', age: 19 }

  describe 'check_all_rules' do
    it 'returns empty array' do
      expected = []
      expect(SeatingRules.check_all_rules(sam, chris, michael)).to eq expected
    end

    it 'returns within 5 error' do
      expected = ["The age difference between Sam and John is greater than 5"]
      expect(SeatingRules.check_all_rules(sam, john, matt)).to eq expected
    end

    it 'returns valley error' do
      expected = ["Michael is younger than both Sam and Chris"]
      expect(SeatingRules.check_all_rules(sam, michael, chris)).to eq expected
    end

    it 'returns both kinds of errors' do
      expected = ["The age difference between John and Michael is greater than 5",
                  "Michael is younger than both Sam and John"]
      expect(SeatingRules.check_all_rules(sam, michael, john)).to eq expected
    end
  end

  describe 'check_within_5' do
    it 'returns empty error array' do
      expect(SeatingRules.check_within_5(sam, chris, michael)).to eq []
    end

    it 'returns error for one side' do
      expected = ["The age difference between Sam and John is greater than 5"]
      expect(SeatingRules.check_within_5(sam, john, matt)).to eq expected
    end

    it 'returns error for both sides' do
      expected = ["The age difference between Sam and John is greater than 5",
                  "The age difference between Chris and John is greater than 5"]
      expect(SeatingRules.check_within_5(sam, john, chris)).to eq expected
    end
  end

  describe 'check_within_x' do
    it 'returns nil when difference is less than or equal x' do
      expect(SeatingRules.check_within_x(sam, chris, 3)).to eq nil
    end

    it 'returns an error message when difference is greater than x' do
      expected = "The age difference between Sam and John is greater than 3"
      expect(SeatingRules.check_within_x(sam, john, 3)).to eq expected
    end
  end

  describe 'check_valley' do
    it 'returns nil' do
      expect(SeatingRules.check_valley(sam, chris, michael)).to eq nil
    end

    it 'returns an error' do
      expected = "Michael is younger than both Sam and Chris"
      expect(SeatingRules.check_valley(sam, michael, chris)).to eq expected
    end
  end
end
