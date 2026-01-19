module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    token = extract_token
    return render_unauthorized unless token

    access_token = AccessToken.find_valid_token(token)
    return render_unauthorized unless access_token

    @current_user = access_token.user
  end

  def current_user
    @current_user
  end

  def extract_token
    # Bearer トークンから取得
    auth_header = request.headers["Authorization"]
    if auth_header&.start_with?("Bearer ")
      return auth_header.split(" ").last
    end

    # Cookie から取得
    cookies[:access_token]
  end

  def render_unauthorized
    render json: { error: "認証が必要です", success: false }, status: :unauthorized
  end
end

