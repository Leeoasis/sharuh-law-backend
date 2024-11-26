class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum role: { client: "client", lawyer: "lawyer" }

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
    validates :specializations, presence: true
    validates :experience_years, presence: true, numericality: { only_integer: true }
  end
end
