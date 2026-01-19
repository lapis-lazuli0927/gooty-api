class UsersController < ApplicationController
  include Authenticatable

  def index
    users = User.all
    render json: {
      data: users.map { |user| user_response(user) },
      success: true
    }
  end

  def show
    user = User.find_by(id: params[:id])

    unless user
      return render json: {
        error: "ユーザーが見つかりません",
        success: false
      }, status: :not_found
    end

    render json: {
      data: user_response(user),
      success: true
    }
  end

  def update
    user = User.find_by(id: params[:id])

    unless user
      return render json: {
        error: "ユーザーが見つかりません",
        success: false
      }, status: :not_found
    end

    if user.update(update_params)
      render json: {
        data: user_response(user),
        success: true
      }
    else
      render json: {
        errors: user.errors.full_messages,
        success: false
      }, status: :bad_request
    end
  end

  def destroy
    user = User.find_by(id: params[:id])

    unless user
      return render json: {
        error: "ユーザーが見つかりません",
        success: false
      }, status: :not_found
    end

    user.destroy!

    render json: { success: true }, status: :ok
  end

  private

  def update_params
    params.permit(:email, :name, :password)
  end

  def user_response(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      created_at: user.created_at
    }
  end
end

