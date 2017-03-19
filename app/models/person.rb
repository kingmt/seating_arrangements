class Person < ApplicationRecord
  has_one :seat

  validates :name, :age, presence: true

  # use !! to force value to be true or false
  def seated
    !!seat
  end

  def seated_at_table
    if seated
      seat.table_id
    else
      nil
    end
  end
end
