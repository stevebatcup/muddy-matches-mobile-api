class SubscriptionsController < ApplicationController
  before_action :authorise_user!

  def create
    return render json: { error: I18n.t('profile_not_ready') }, status: 403 unless current_user.profile.visible_and_approved?

    begin
      current_user.setup_subscription(subscription_params[:days].to_i)
      render json: { status: :success }
    rescue ActionController::ParameterMissing
      render json: { status: :fail, error: I18n.t('subscribe.error.missing_days') }, status: 500
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:days)
  end
end
