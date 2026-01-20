class DropStardustsTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :stardusts
  end

  def down
    create_table :stardusts do |t|
      t.string :value
      t.timestamps
    end
    
    change_column :stardusts, :value, :integer
    add_column :stardusts, :memo, :string
  end
end
