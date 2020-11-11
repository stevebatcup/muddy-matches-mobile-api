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

  def create
    user = User.find(params[:id])
    current_user.add_favourite(user)

    if current_user.profile.errors.any?
      error_msg = current_user.profile.favouritisations.last.errors.full_messages
      render json: { status: :fail, error: error_msg }
    else
      render json: { status: :success }
    end
  end

  def destroy
    @fave = Favourite.find(params[:id])
    delete_result = params[:favourited].present? ? delete_favourited : delete_favouriter

    if delete_result
      render json: { status: :success }
    else
      render json: { status: :fail }
    end
  end

  private

  def delete_favouriter
    if @fave.favouriter_status == 'active' && @fave.profile_id == current_user.profile_id
      @fave.delete_for_favouriter
      true
    else
      false
    end
  end

  def delete_favourited
    if @fave.favourited_status == 'active' && @fave.favourite_profile_id == current_user.profile_id
      @fave.delete_for_favourited
      true
    else
      false
    end
  end
end
