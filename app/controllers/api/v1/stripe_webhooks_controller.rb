class Api::V1::StripeWebhooksController < ApplicationController
  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    secret = ENV["STRIPE_WEBHOOK_SECRET"]

    event = if secret.present?
              Stripe::Webhook.construct_event(payload, sig_header, secret)
    else
              JSON.parse(payload, symbolize_names: true)
    end

    PaymentEvent.find_or_create_by!(stripe_event_id: event.id) do |pe|
      pe.event_type = event.type
      pe.payload = event.to_hash
      pe.processed_at = Time.current
    end

    handle_event(event)

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end

  def handle_event(event)
    case event.type
    when "checkout.session.completed"
      sub_id = event.data.object.metadata["subscription_id"]
      if sub_id
        sub = Subscription.find_by(id: sub_id)
        sub&.update!(
          status: "active",
          stripe_subscription_id: event.data.object.subscription
        )
      end
    end
  end
end
