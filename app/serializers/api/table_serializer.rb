class Api::TableSerializer < ActiveModel::Serializer
  attributes :id, :seats

  def seats
    object.seats.collect {|s| Api::SeatSerializer.new(s) }
  end
end
