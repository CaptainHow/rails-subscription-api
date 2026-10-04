class Api::V1::PlansController < ApplicationController
  def index
    render json: Plan.where(active: true)
  end

  def show
    render json: Plan.find(params[:id])
  end
end
