class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  #        :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum role: { client: "client", lawyer: "lawyer", admin: "admin" }

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :name, presence: true
  validates :role, presence: true

  # Phone number validation for lawyers
  with_options if: -> { role == "lawyer" } do
    validates :phone_number, presence: true
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
end
