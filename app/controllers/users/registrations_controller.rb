class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  respond_to :json

  def create
    user = User.new(sign_up_params)

    # Attach uploaded files (if present)
    attach_documents(user)

    if user.save
      render json: {
        user: user.as_json(only: [:id, :name, :email, :role, :approved]),
        role: user.role
      }, status: :created
    else
      Rails.logger.debug "User save failed: #{user.errors.full_messages.join(', ')}"
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :role, :preferred_language, :budget, :license_number,
      :areas_of_expertise, :experience_years, :preferred_court, :rate,
      :admission_enrollment_order, :good_standing_letter, :fidelity_fund_certificate, :id_document,
      :engagement_form, :client_id_document, :client_proof_of_address,
      :phone_number # <-- Added phone_number here
    ])
  end

  def sign_up_params
    params.require(:registration).permit(
      :email, :password, :password_confirmation, :name, :role, :preferred_language,
      :budget, :license_number, :areas_of_expertise, :experience_years, :preferred_court,
      :rate, :admission_enrollment_order, :good_standing_letter, :fidelity_fund_certificate,
      :id_document, :engagement_form, :client_id_document, :client_proof_of_address,
      :phone_number # <-- Added phone_number here
    )
  end

  def attach_documents(user)
    file_fields = %i[
      admission_enrollment_order,
      good_standing_letter,
      fidelity_fund_certificate,
      id_document,
      engagement_form,
      client_id_document,
      client_proof_of_address
    ]

    file_fields.each do |field|
      user.send(field).attach(params[:registration][field]) if params[:registration][field].present?
    end
  end
end