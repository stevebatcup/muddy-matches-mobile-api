class ApplicationController < ActionController::API
  def authorise_user!
    return render json: { status: :unauthorised }, status: 403 if current_user.nil?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
