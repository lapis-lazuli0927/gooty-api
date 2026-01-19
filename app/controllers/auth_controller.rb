class AuthController < ApplicationController
  def signup
    user = User.new(signup_params)

    if user.save
      access_token = user.access_tokens.create!
      set_token_cookie(access_token.token)

      render json: {
        data: user_response(user),
        token: access_token.token,
        success: true
      }, status: :created
    else
      render json: {
        errors: user.errors.full_messages,
        success: false
      }, status: :bad_request
    end
  end

  def login
    user = User.find_by(email: login_params[:email])

    unless user&.authenticate(login_params[:password])
      return render json: {
        error: "メールアドレスまたはパスワードが正しくありません",
        success: false
      }, status: :unauthorized
    end

    access_token = user.access_tokens.create!
    set_token_cookie(access_token.token)

    render json: {
      data: user_response(user),
      token: access_token.token,
      success: true
    }, status: :ok
  end

  def logout
    token = extract_token
    if token
      access_token = AccessToken.find_by(token: token)
      access_token&.destroy
    end

    cookies.delete(:access_token)

    render json: { success: true }, status: :ok
  end

  private

  def signup_params
    params.permit(:email, :password, :name)
  end

  def login_params
    params.permit(:email, :password)
  end

  def extract_token
    auth_header = request.headers["Authorization"]
    if auth_header&.start_with?("Bearer ")
      return auth_header.split(" ").last
    end

    cookies[:access_token]
  end

  def set_token_cookie(token)
    cookies[:access_token] = {
      value: token,
      expires: 30.days.from_now,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
  end

  def user_response(user)
    {
      id: user.id,
      email: user.email,
      name: user.name
    }
  end
end

