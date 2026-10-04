class Api::V1::StripeWebhooksController < ApplicationController
  def create
    PaymentEvent.create!(
          stripe_event_id: params[:id].presence || SecureRandom.uuid,
          event_type: params[:type].presence || "test.event",
          payload: request.request_parameters,
          processed_at: Time.current
    )
    head :ok
  end
end
