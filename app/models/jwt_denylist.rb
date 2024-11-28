class JwtDenylist < ApplicationRecord
  self.table_name = "jwt_denylists"
  # This will store the "jti" and "exp" fields of the JWT
  # Ensure the jti field is unique
  validates :jti, presence: true, uniqueness: true
end
