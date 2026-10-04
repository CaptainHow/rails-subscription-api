require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "create user with valid params" do
    assert_difference("User.count", 1) do
      post api_v1_users_url,
        params: {
          user: {
            email: "newuser@example.com",
            password: "secret123",
            password_confirmation: "secret123"
          }
        },
        as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "newuser@example.com", json["email"]
    assert json["id"].present?
  end

  test "create user with invalid params returns error" do
    assert_no_difference("User.count") do
      post api_v1_users_url,
        params: {
          user: {
            email: "",
            password: "short",
            password_confirmation: "short"
          }
        },
        as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].present?
  end
end
