class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan
  validates :status, inclusion: { in: %w[pending active canceled] }
end
