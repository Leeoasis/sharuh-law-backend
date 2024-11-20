# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { message: "Signed up successfully", user: resource }, status: :ok
    else
      render json: { message: "User could not be created", errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :role)
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :name, :role)
  end
end
