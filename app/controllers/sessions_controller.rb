class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user
      if user.authenticate(params[:password])
        sign_in_success(user)
      else
        sign_in_fail
      end
    else
      sign_in_fail
    end
  end

  def destroy
    session.clear
    render json: { status: :success }
  end

  private

  def sign_in_success(user)
    session[:user_id] = user.id
    render json: {
      status: :success,
      user:   {
        id:        user.id,
        firstName: user.firstname,
        lastName:  user.lastname,
        email:     user.email
      }
    }
  end

  def sign_in_fail
    render json: { status: :fail, error: 'Invalid email or password' }, status: 403
  end
end
