class ConnectsController < ApplicationController
  before_action :authorise_user!

  def create
    profile = Profile.find(params[:profile_id])
    case params[:mode]
    when :approve
      current_user.approve_connect(profile)
      render json: { status: 'success', action: 'approved' }
    when :reject
      current_user.reject_connect(profile)
      render json: { status: 'success', action: 'rejected' }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'fail' }, status: 500
  end
end
