class Seat < ApplicationRecord
  belongs_to :table
  belongs_to :person

  acts_as_list scope: :table

  def name
    if person
      person.name
    else
      nil
    end
  end

  def age
    if person
      person.age
    else
      nil
    end
  end

  def can_be_unseated
    TableRules.can_be_unseated table.seats.to_a, self
  end
end
