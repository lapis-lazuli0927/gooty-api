class AccessToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :generate_token, on: :create
  before_validation :set_expires_at, on: :create

  scope :valid, -> { where("expires_at > ?", Time.current) }

  def expired?
    expires_at < Time.current
  end

  def self.find_valid_token(token)
    valid.find_by(token: token)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expires_at
    self.expires_at ||= 30.days.from_now
  end
end

