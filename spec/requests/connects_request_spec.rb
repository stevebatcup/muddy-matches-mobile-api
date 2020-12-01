require 'rails_helper'

RSpec.fdescribe 'Connects', type: :request do
  include SpecHelpers

  before :all do
    @current_user = create(:subscribing_user, email: 'connecto@foo.com', password: 'a_password', firstname: 'Steve')
    create(:approved_profile, user: @current_user, gender: 'male', dating_looking_for: 'female')
  end

  before(:each) { sign_in(@current_user.email, 'a_password') }
  after(:each) { sign_out }

  it 'approves the connect profile' do
    user = create(:user, firstname: 'Great', lastname: 'Person', created: 20.days.ago)
    profile = create(:approved_profile, user: user)

    post approve_connect_path, params: { profile_id: profile.id }, headers: json_headers

    expect(response).to have_http_status(200)
    expect(json_response['status']).to eq 'success'
    expect(json_response['action']).to eq 'approved'
  end

  it 'does not approve the connect profile if it does not exist' do
    post approve_connect_path, params: { profile_id: 123 }, headers: json_headers

    expect(response).to have_http_status(500)
    expect(json_response['status']).to eq 'fail'
  end

  it 'rejects the connect profile' do
    user = create(:user, firstname: 'Great', lastname: 'Person', created: 20.days.ago)
    profile = create(:approved_profile, user: user)

    post reject_connect_path, params: { profile_id: profile.id }, headers: json_headers

    expect(response).to have_http_status(200)
    expect(json_response['status']).to eq 'success'
    expect(json_response['action']).to eq 'rejected'
  end

  it 'does not reject the connect profile if it does not exist' do
    post reject_connect_path, params: { profile_id: 123 }, headers: json_headers

    expect(response).to have_http_status(500)
    expect(json_response['status']).to eq 'fail'
  end
end
