class ApplicationController < ActionController::API
  def authorise_user!
    return render json: { status: :unauthorised, error: 'You must be signed in' }, status: 403 unless user_signed_in?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end
end
