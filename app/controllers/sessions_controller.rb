class SessionsController < ApplicationController
  def new
    user = User.find_by(email: params[:email])
    if user
      if user.authenticate(params[:password])
        sign_in_success
      else
        sign_in_fail
      end
    else
      sign_in_fail
    end
  end

  private

  def sign_in_success
    render json: { status: :success }
  end

  def sign_in_fail
    render json: { status: :fail }
  end
end
