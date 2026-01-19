class ChangeUserIdNotNullOnShops < ActiveRecord::Migration[8.0]
  def up
    # このマイグレーションを実行する前に、rake shops:assign_default_user を実行してください
    # 既存のShopデータにuser_idが設定されていることを確認
    if Shop.where(user_id: nil).exists?
      raise "user_idがnullのShopデータが存在します。先に rake shops:assign_default_user を実行してください。"
    end

    change_column_null :shops, :user_id, false
  end

  def down
    change_column_null :shops, :user_id, true
  end
end

