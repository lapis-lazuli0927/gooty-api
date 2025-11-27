class CreateStardusts < ActiveRecord::Migration[8.0]
  def change
    create_table :stardusts do |t|
      t.string :value
      t.timestamps
    end
  end
end
