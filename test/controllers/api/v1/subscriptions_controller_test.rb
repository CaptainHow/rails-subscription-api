require "test_helper"

class Api::V1::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "create subscription" do
    user = users(:one)
    plan = plans(:one)

    assert_difference("Subscription.count", 1) do
      post api_v1_subscriptions_url,
        params: { user_id: user.id, plan_id: plan.id },
        as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "pending", json["status"]
    assert_equal plan.id, json["plan_id"]
  end

  test "show subscriptions" do
    sub = subscriptions(:one)
    get api_v1_subscription_url(sub)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal sub.id, json["id"]
    assert_equal sub.status, json["status"]
  end
end
