class CreateSeats < ActiveRecord::Migration[5.0]
  def change
    create_table :seats do |t|
      t.references :table, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
