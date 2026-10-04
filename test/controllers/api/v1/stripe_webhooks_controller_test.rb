require "test_helper"

class Api::V1::StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  test "stores payment event and returns ok" do
    stripe_event_id = "evt_test_123"

    assert_difference("PaymentEvent.count", 1) do
      post api_v1_webhooks_stripe_url,
        params: { id: stripe_event_id, type: "checkout.session.completed" },
        as: :json
    end

    assert_response :success
    event = PaymentEvent.find_by!(stripe_event_id: stripe_event_id)
    assert_equal "evt_test_123", event.stripe_event_id
    assert_equal "checkout.session.completed", event.event_type
  end
end
