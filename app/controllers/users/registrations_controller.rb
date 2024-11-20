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
    params.require(:user).permit(
      :email, :password, :password_confirmation, :name, :role, :phone_number, :profile_picture, :address,
      :license_number, :specializations, :experience_years, :bio, :languages, :hourly_rate, :office_address,
      :practice_state, :average_rating, :review_count, :certifications, :verification_status, :portfolio_url,
      :preferred_language, :budget, :case_type, :current_case_id
    )
  end

  def account_update_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :current_password, :name, :role, :phone_number, :profile_picture, :address,
      :license_number, :specializations, :experience_years, :bio, :languages, :hourly_rate, :office_address,
      :practice_state, :average_rating, :review_count, :certifications, :verification_status, :portfolio_url,
      :preferred_language, :budget, :case_type, :current_case_id
    )
  end
end
