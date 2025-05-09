class Case < ApplicationRecord
  belongs_to :client, class_name: "User", foreign_key: "client_id"
  belongs_to :lawyer, class_name: "User", foreign_key: "lawyer_id", optional: true
  has_many :notifications, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :client, presence: true
  validates :case_type, presence: true
end
