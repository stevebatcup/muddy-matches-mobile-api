class FavouritesController < ApplicationController
  before_action :authorise_user!

  def index
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    @profiles = if params[:fans].present?
                  @mode = :fans
                  current_user.fans.page(page).per(per_page)
                elsif params[:mutuals].present?
                  @mode = :mutuals
                  offset = (page - 1) * per_page
                  current_user.mutuals.slice(offset, per_page)
                else
                  @mode = :favourites
                  current_user.favourites.page(page).per(per_page)
                end
  end
end
