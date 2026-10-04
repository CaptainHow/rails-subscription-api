class PaymentEvent < ApplicationRecord
  validates :stripe_event_id, :event_type, presence: true
end
