class Api::V1::SubscriptionsController < ApplicationController
  def create
    user = User.find(params[:user_id])
    plan = Plan.find(params[:plan_id])
    sub = user.subscriptions.create!(plan: plan, status: "pending")
    render json: { id: sub.id, status: sub.status, plan_id: plan.id }, status: :created
  end

  def show
    render json: Subscription.find(params[:id])
  end
end
