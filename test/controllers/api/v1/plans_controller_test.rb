require "test_helper"

class Api::V1::PlansControllerTest < ActionDispatch::IntegrationTest
  test "index returns only active plans" do
    get api_v1_plans_url
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    assert json.all? { |plan| plan["active"] == true }
    assert_includes json.map { |p| p["name"] }, plans(:one).name
    refute_includes json.map { |p| p["name"] }, plans(:two).name
  end

  test "show returns one plan" do
    plan = plans(:one)
    get api_v1_plan_url(plan)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal plan.id, json["id"]
    assert_equal plan.name, json["name"]
  end
end
