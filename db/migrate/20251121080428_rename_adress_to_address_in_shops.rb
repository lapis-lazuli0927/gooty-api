class RenameAdressToAddressInShops < ActiveRecord::Migration[8.0]
  def change
    rename_column :shops, :adress, :address
    change_column :shops, :tel, :string
  end
end