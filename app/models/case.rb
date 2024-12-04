class Case < ApplicationRecord
  belongs_to :client, class_name: 'User', foreign_key: 'client_id'
  belongs_to :lawyer, class_name: 'User', foreign_key: 'lawyer_id', optional: true

  validates :title, presence: true
  validates :description, presence: true
  validates :client, presence: true
end