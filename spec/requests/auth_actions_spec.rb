require 'rails_helper'
require 'support/helpers'

RSpec.describe 'Auth actions', type: :request do
  include SpecHelpers

  describe 'POST /sign_in' do
    before :all do
      @user = create(:user, email: 'foo@bar.com', password: '123abc456xyz')
    end

    it 'signs in a user with the correct email and password' do
      post sign_in_path, params: { email: 'foo@bar.com', password: '123abc456xyz' }, headers: json_headers

      data = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(data['status']).to eq('success')
    end

    it 'does not sign in a user with the wrong email address' do
      post sign_in_path, params: { email: 'bar@foo.com', password: '123abc456xyz' }, headers: json_headers

      data = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(data['status']).to eq('fail')
    end

    it 'does not sign in a user with the wrong password' do
      post sign_in_path, params: { email: 'foo@bar.com', password: 'foo' }, headers: json_headers

      data = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(data['status']).to eq('fail')
    end

    xit 'signs out a user' do
      delete sign_out_path
    end
  end
end
