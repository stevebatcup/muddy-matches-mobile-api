class FavouritesController < ApplicationController
  before_action :authorise_user!

  def index
    @status = :success
    render :index
  end
end
