# config/initializers/devise_permitted_parameters.rb
Devise.setup do |config|
  # Nothing to change here for params — setup remains as is.
end

# Extend Devise's param sanitizer
Rails.application.config.to_prepare do
  Devise::RegistrationsController.class_eval do
    before_action :configure_permitted_parameters

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [
        :name,
        :role,
        # Lawyer-specific
        :admission_order,
        :enrollment_order,
        :good_standing_letter,
        :fidelity_fund_certificate,
        :id_document,
        :practice_address,
        :preferred_court,
        # Client-specific
        :engagement_form,
        :client_id_document,
        :client_proof_of_address
      ])
      devise_parameter_sanitizer.permit(:account_update, keys: [
        :name,
        :role,
        :admission_order,
        :enrollment_order,
        :good_standing_letter,
        :fidelity_fund_certificate,
        :id_document,
        :practice_address,
        :preferred_court,
        :engagement_form,
        :client_id_document,
        :client_proof_of_address
      ])
    end
  end
end
