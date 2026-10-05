class CheckoutResultsController < ApplicationController
  def success
    render json: {
      message: "Payment successful. Your subscription should be active shortly.",
      session_id: params[:session_id]
    }
  end

  def cancel
    render json: { message: "Checkout canceled. No payment was made." }
  end
end
