require 'rails_helper'

RSpec.describe 'Subscriptions', type: :request do
  include SpecHelpers

  describe 'completes the in-app purchase by creating a back-end subscription' do
    context 'signed in' do
      before(:all) do
        @user = create(:user, email: 'miles@bar.com', password: 'the_password')
        create(:approved_profile, user: @user)
      end

      before(:each) { sign_in(@user.email, 'the_password') }
      after(:each) { sign_out }

      it 'creates a sub' do
        post subscribed_path, params: subscription_params, headers: json_headers

        expect(response).to have_http_status(200)
        expect(json_response['status']).to eq 'success'
        expect(@user.reload.subscriber?).to be_truthy
      end

      it 'does not create a sub and sends back an error if days are not specified' do
        post subscribed_path, params: { subscription: {} }, headers: json_headers

        expect(response).to have_http_status(500)
        expect(json_response['status']).to eq 'fail'
        expect(json_response['error']).to eq 'You must specify the amount of days for this subscription'
      end

      it 'does not create a sub and sends back an error message if profile is not ready' do
        sign_out
        lazy_user = create(:subscribing_user, email: 'lazy@foo.com', password: 'a_password', firstname: 'Lazy')
        create(:profile, visibility_status: 'hidden', user: lazy_user)
        sign_in(lazy_user.email, 'a_password')

        post subscribed_path, params: subscription_params, headers: json_headers

        expect(response).to have_http_status(403)
        expect(json_response['error']).to eq 'You must have a visible and approved profile'
      end
    end

    it 'does not create a sub and sends back an error if not signed in' do
      post subscribed_path, params: subscription_params, headers: json_headers

      expect(response).to have_http_status(403)
      expect(json_response['error']).to eq 'You must be signed in'
    end

    def subscription_params
      { subscription: { days: 30 } }
    end
  end
end
