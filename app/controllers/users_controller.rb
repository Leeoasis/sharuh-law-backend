class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  # GET /api/lawyers
  def lawyers
    @lawyers = User.lawyer.where(search_params)
    render json: @lawyers
  end

  def clients
    @clients = User.client.where(search_params)
    render json: @clients
  end

  # PUT /api/user/:id
  def update_profile
    @user = User.find_by(id: params[:id])

    if @user.nil?
      render json: { error: "User not found" }, status: :not_found
      return
    end

    if @user.update(user_params)
      render json: { message: "Profile updated successfully" }, status: :ok
    else
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/user/profile
  def profile
    @user = User.find_by(role: params[:role])

    if @user.nil?
      render json: { error: "User not found" }, status: :not_found
    else
      render json: @user, status: :ok
    end
  end

  private

  def search_params
    params.permit(:specializations, :experience_years, :preferred_language, :budget, :license_number)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :preferred_language, :budget, :license_number, :specializations, :experience_years)
  end
end
