require 'rails_helper'

RSpec.describe 'Subscriptions', type: :request do
  include SpecHelpers

  describe 'completes the in-app purchase by creating a back-end subscription' do
    before(:all) do
      @user = create(:user, email: 'james@bar.com', password: 'the_password')
    end

    before(:each) { sign_in(@user.email, 'the_password') }
    after(:each) { sign_out }

    it 'creates a sub' do
      post subscribed_path, params: { subscription: { days: 30 } }, headers: json_headers

      expect(response).to have_http_status(200)
      expect(json_response['status']).to eq 'success'
      expect(@user.reload.subscriber?).to be_truthy
    end

    it 'does not create a sub and raises an error if days are not specified' do
      expect do
        post subscribed_path, params: { subscription: {} }, headers: json_headers
      end.to raise_exception(ActionController::ParameterMissing)
    end
  end
end
