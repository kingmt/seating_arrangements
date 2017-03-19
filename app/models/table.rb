class Table < ApplicationRecord
  has_many :seats, -> { order(position: :asc) }, dependent: :destroy
  has_many :people, through: :seats
end
