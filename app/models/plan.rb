class Plan < ApplicationRecord
  validates :name, :stripe_price_id, :amount_cents, :interval, presence: true
  validates :interval, inclusion: { in: %w[month year] }
  has_many :subscriptions
end
