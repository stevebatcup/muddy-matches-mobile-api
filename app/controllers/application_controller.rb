class ApplicationController < ActionController::API
  def authorise_user!
    return render json: { status: :unauthorised, error: 'You must be signed in' }, status: 403 unless user_signed_in?
  end

  helper_method :current_user
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  helper_method :user_signed_in?
  def user_signed_in?
    current_user.present?
  end
end
