namespace :shops do
  desc "既存のShopデータにデフォルトユーザーを紐付ける"
  task assign_default_user: :environment do
    # デフォルトユーザーのメールアドレス（環境変数または引数で指定可能）
    default_email = ENV["DEFAULT_USER_EMAIL"] || "admin@example.com"
    default_password = ENV["DEFAULT_USER_PASSWORD"] || "password123"
    default_name = ENV["DEFAULT_USER_NAME"] || "Admin User"

    puts "=== 既存Shopデータへのユーザー紐付けタスク開始 ==="

    # デフォルトユーザーを取得または作成
    user = User.find_by(email: default_email)
    
    if user.nil?
      puts "デフォルトユーザーが存在しないため、新規作成します..."
      user = User.create!(
        email: default_email,
        password: default_password,
        name: default_name
      )
      puts "ユーザー作成完了: #{user.email} (ID: #{user.id})"
    else
      puts "既存ユーザーを使用: #{user.email} (ID: #{user.id})"
    end

    # user_idがnullのShopを取得
    shops_without_user = Shop.where(user_id: nil)
    total_count = shops_without_user.count

    if total_count == 0
      puts "紐付けが必要なShopデータはありません。"
      puts "=== タスク完了 ==="
      next
    end

    puts "#{total_count}件のShopデータを更新します..."

    # 一括更新
    updated_count = shops_without_user.update_all(user_id: user.id)

    puts "#{updated_count}件のShopデータを更新しました。"
    puts "=== タスク完了 ==="
  end
end

