class UserSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :email, :role, :approved, :license_number, :experience_years, :rate,
             :areas_of_expertise, :preferred_court,
             :admission_enrollment_order, :good_standing_letter, :fidelity_fund_certificate,
             :id_document, :engagement_form, :client_id_document, :client_proof_of_address

  def admission_enrollment_order
    return unless object.admission_enrollment_order.attached?
    rails_blob_url(object.admission_enrollment_order, host: default_url_host)
  end

  def good_standing_letter
    return unless object.good_standing_letter.attached?
    rails_blob_url(object.good_standing_letter, host: default_url_host)
  end

  def fidelity_fund_certificate
    return unless object.fidelity_fund_certificate.attached?
    rails_blob_url(object.fidelity_fund_certificate, host: default_url_host)
  end

  def id_document
    return unless object.id_document.attached?
    rails_blob_url(object.id_document, host: default_url_host)
  end

  def engagement_form
    return unless object.engagement_form.attached?
    rails_blob_url(object.engagement_form, host: default_url_host)
  end

  def client_id_document
    return unless object.client_id_document.attached?
    rails_blob_url(object.client_id_document, host: default_url_host)
  end

  def client_proof_of_address
    return unless object.client_proof_of_address.attached?
    rails_blob_url(object.client_proof_of_address, host: default_url_host)
  end

  private

  def default_url_host
    Rails.application.routes.default_url_options[:host] || "http://localhost:3000"
  end
end
