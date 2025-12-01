class CreateStations < ActiveRecord::Migration[8.0]
  def change
    create_table :stations do |t|
      t.string :name, limit: 30, null: false
      t.timestamps
    end
  end
end
