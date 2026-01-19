class AddUserIdToShops < ActiveRecord::Migration[8.0]
  def change
    # 一旦nullを許容して追加（既存データがある場合のため）
    add_reference :shops, :user, null: true, foreign_key: true
  end
end

