class Seat < ApplicationRecord
  belongs_to :table
  belongs_to :person
end
