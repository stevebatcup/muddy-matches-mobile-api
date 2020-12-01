class SearchController < ApplicationController
  include ActionController::Helpers
  helper ProfileHelper

  before_action :authorise_user!

  def index
    @profiles = Profile.connects_for_user(current_user, search_params)
                       .page(params[:page])
                       .per(params[:per_page])
  end

  private

  def search_params
    params.require(:search).permit(:age_min, :age_max, :page, :per_page)
  end
end
