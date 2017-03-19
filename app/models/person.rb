class Person < ApplicationRecord
  has_one :seat

  validates :name, :age, presence: true
end
