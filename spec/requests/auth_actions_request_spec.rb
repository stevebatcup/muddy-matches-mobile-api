require 'rails_helper'
require 'support/helpers'

RSpec.describe 'Auth actions', type: :request do
  include SpecHelpers

  before :all do
    @user = create(:user, email: 'james@bar.com', password: 'the_password', firstname: 'Steve')
  end

  describe 'POST /sign_in' do
    it 'signs in a user with the correct email and password' do
      sign_in(@user.email, 'the_password')

      expect(response).to have_http_status(200)
      expect(json_response['status']).to eq('success')
      expect(json_response['user']['firstname']).to eq 'Steve'

      cookie = get_cookie(cookies, '_session_id')
      expect(cookie).to be_present
      expect(cookie.domain).to eq ENV['RAILS_TEST_DOMAIN']
    end

    it 'does not sign in a user with the wrong email address' do
      post sign_in_path, params: { email: 'bar@james.com', password: 'the_password' }, headers: json_headers

      expect(response).to have_http_status(403)
      expect(json_response['status']).to eq('fail')

      cookie = get_cookie(cookies, '_session_id')
      expect(cookie).to_not be_present
    end

    it 'does not sign in a user with the wrong password' do
      post sign_in_path, params: { email: 'james@bar.com', password: 'bad_password' }, headers: json_headers

      expect(response).to have_http_status(403)
      expect(json_response['status']).to eq('fail')

      cookie = get_cookie(cookies, '_session_id')
      expect(cookie).to_not be_present
    end
  end

  describe 'DELETE /sign_out' do
    it 'signs out a user' do
      delete sign_out_path

      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /favourites' do
    it 'denies access to a restricted resource for a non signed-in user' do
      get favourites_path

      expect(response).to have_http_status(403)
      expect(json_response['error']).to eq 'You must be signed in'
    end

    it 'denies access to a restricted resource for a user who has signed out' do
      sign_in(@user.email, 'the_password')
      delete sign_out_path
      get favourites_path

      expect(response).to have_http_status(403)
      expect(json_response['error']).to eq 'You must be signed in'
    end
  end
end
