class Api::V1::CheckoutSessionsController < ApplicationController
  def create
    subscription = Subscription.find(params[:subscription_id])
    plan = subscription.plan

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      line_items: [ { price: plan.stripe_price_id, quantity: 1 } ],
      success_url: params.fetch(:success_url, "http://localhost:3000/success"),
      cancel_url: params.fetch(:cancel_url, "http://localhost:3000/cancel"),
      metadata:  { subscription_id: subscription.id.to_s },
    )

    render json: { checkout_url: session.url, session_id: session.id }, status: :created
  rescue Stripe::StripeError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
