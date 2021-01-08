class ProfilesController < ApplicationController
  include ActionController::Helpers
  helper ProfileHelper

  before_action :authorise_user!

  def show
    @profile = Profile.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: :fail, error: I18n.t('profiles.not_found') }, status: 500
  end
end
