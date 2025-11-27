class ChangeValueToIntegerAndAddMemoToStardusts < ActiveRecord::Migration[8.0]
  def change
    change_column :stardusts, :value, :integer
    add_column :stardusts, :memo, :string
  end
end
