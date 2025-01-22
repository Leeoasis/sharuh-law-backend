class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :case, optional: true
  validates :message, presence: true
end
