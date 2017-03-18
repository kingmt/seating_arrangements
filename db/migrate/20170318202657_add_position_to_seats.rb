class AddPositionToSeats < ActiveRecord::Migration[5.0]
  def change
    add_column :seats, :position, :integer
  end
end
