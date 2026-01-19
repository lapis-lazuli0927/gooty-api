class User < ApplicationRecord
  has_secure_password

  has_many :access_tokens, dependent: :destroy
  has_many :shops, dependent: :nullify

  validates :email, presence: { message: "メールアドレスは必須です" },
                    uniqueness: { message: "このメールアドレスは既に使用されています" },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "メールアドレスの形式が正しくありません" }
  validates :name, presence: { message: "名前は必須です" }
  validates :password, presence: { message: "パスワードは必須です" }, length: { minimum: 6, message: "パスワードは6文字以上で入力してください" }, on: :create
end

