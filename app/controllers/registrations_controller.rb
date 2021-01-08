class RegistrationsController < ApplicationController
  def create
    return render json: { error: 'You are already signed in' }, status: 403 if user_signed_in?

    profile = Profile.build_default(profile_params)
    profile.user = User.new(user_params)

    if profile.save
      UserEvent.log_registration(profile)
      render json: { status: :success, user: profile.user.to_json_data, profile: profile.to_json_data }
    else
      UserEvent.log_registration_form_error(profile.errors.to_hash)
      error_messages = profile.user.errors.any? ? profile.user.errors.full_messages : profile.errors.full_messages
      render json: { status: :fail, error: error_messages }
    end
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :password)
  end

  def profile_params
    params.require(:profile).permit(:dating_looking_for, :gender)
  end
end
