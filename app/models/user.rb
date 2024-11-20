class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatables,
   :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

   enum role: { client: "client", lawyer: "lawyer" }

  validates :role, presence: true
end
