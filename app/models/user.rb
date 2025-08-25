class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
        #  :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum :role, { client: "client", lawyer: "lawyer", admin: "admin" }

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :name, presence: true
  validates :role, presence: true

  # Phone number validation for lawyers
  with_options if: -> { role == "lawyer" } do
    validates :phone_number, presence: true
    # validates :admission_order, presence: true
    # validates :enrollment_order, presence: true
    # validates :good_standing_letter, presence: true
    # validates :fidelity_fund_certificate, presence: true
    # validates :id_document, presence: true
    # validates :practice_address, presence: true
    # validates :preferred_court, presence: true
  end

  with_options if: -> { role == "client" } do
    # validates :engagement_form, presence: true
    # validates :client_id_document, presence: true
    # validates :client_proof_of_address, presence: true
  end

  has_many :client_cases, class_name: "Case", foreign_key: "client_id", dependent: :destroy
  has_many :lawyer_cases, class_name: "Case", foreign_key: "lawyer_id", dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one_attached :admission_enrollment_order
  has_one_attached :good_standing_letter
  has_one_attached :fidelity_fund_certificate
  has_one_attached :id_document
  has_one_attached :engagement_form
  has_one_attached :client_id_document
  has_one_attached :client_proof_of_address

  # Send SMS when lawyer is approved
  # after_update :send_approval_sms, if: :saved_change_to_approved?

  # def send_approval_sms
  #   return unless approved? && phone_number.present?

  #   sid = Rails.application.credentials.dig(:twilio, :account_sid)
  #   token = Rails.application.credentials.dig(:twilio, :auth_token)
  #   from = Rails.application.credentials.dig(:twilio, :phone_number)

  #   return unless sid && token && from

  #   client = Twilio::REST::Client.new(sid, token)
  #   client.messages.create(
  #     from: from,
  #     to: phone_number,
  #     body: "Congratulations! Your registration has been approved. You can now log in to your dashboard."
  #   )
  # rescue Twilio::REST::RestError => e
  #   Rails.logger.error("Twilio error: #{e.message}")
  # end
end
