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

  # PUT /api/user
  def update_profile
    if current_user.update(user_params)
      render json: current_user, status: :ok
    else
      render json: current_user.errors, status: :unprocessable_entity
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