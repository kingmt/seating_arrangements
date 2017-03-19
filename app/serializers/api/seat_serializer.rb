class Api::SeatSerializer < ActiveModel::Serializer
  attributes :id, :name, :age, :can_be_unseated
end
