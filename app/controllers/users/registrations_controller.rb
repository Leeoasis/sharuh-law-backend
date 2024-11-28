class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  respond_to :json

  def create
    build_resource(sign_up_params)

    if resource.save
      render json: { user: resource, role: resource.role }, status: :created
    else
      Rails.logger.debug "User save failed: #{resource.errors.full_messages.join(', ')}"
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :role, :preferred_language, :budget, :license_number, :specializations, :experience_years
    ])
  end

  def sign_up_params
    permitted_params = [ :email, :password, :password_confirmation, :name, :role ]
    if params[:registration][:role] == "lawyer"
      permitted_params += [ :license_number, :specializations, :experience_years ]
    else
      permitted_params += [ :preferred_language, :budget ]
    end
    params.require(:registration).permit(permitted_params)
  end
end
