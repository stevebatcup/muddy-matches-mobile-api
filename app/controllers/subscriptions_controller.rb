class SubscriptionsController < ApplicationController
  def create
    current_user.setup_subscription(subscription_params[:days].to_i)
    render json: { status: :success }
  end

  private

  def subscription_params
    params.require(:subscription).permit(:days)
  end
end
