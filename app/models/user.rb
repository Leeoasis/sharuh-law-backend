class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum :role, { client: "client", lawyer: "lawyer" }

  # Common validations
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
  validates :name, presence: true
  validates :role, presence: true

  # Conditional validations for clients
  with_options if: -> { role == "client" } do
    validates :preferred_language, presence: true
    validates :budget, presence: true, numericality: { only_integer: true }
  end

  # Conditional validations for lawyers
  with_options if: -> { role == "lawyer" } do
    validates :license_number, presence: true
    validates :areas_of_expertise, presence: true
    validates :experience_years, presence: true, numericality: { only_integer: true }
    validates :preferred_court, presence: true
  end

  has_many :client_cases, class_name: "Case", foreign_key: "client_id", dependent: :destroy
  has_many :lawyer_cases, class_name: "Case", foreign_key: "lawyer_id", dependent: :destroy

  # ✅ Add this to fix NoMethodError in NotificationsController
  has_many :notifications, dependent: :destroy
end
