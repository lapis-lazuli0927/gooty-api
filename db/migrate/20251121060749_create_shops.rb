class CreateShops < ActiveRecord::Migration[8.0]
  def change
    create_table :shops do |t|
      t.string :name, limit: 30, null: false
      t.text :url
      t.references :station, foreign_key: true 
      t.string :adress, limit: 30
      t.integer :tel
      t.text :memo
      t.integer :review
      t.boolean :is_ai_generated, null: false
      t.boolean :is_instagram, null: false
      t.timestamps
    end
  end
end
