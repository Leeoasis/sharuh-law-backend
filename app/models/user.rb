class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum :role, { client: "client", lawyer: "lawyer", admin: "admin" }

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :name, presence: true
  validates :role, presence: true

  with_options if: -> { role == "lawyer" } do
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
end
