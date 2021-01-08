require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  include SpecHelpers

  before :all do
    @current_user = create(:subscribing_user, email: 'profileman@bar.com', password: 'a_password')
    @current_profile = create(:profile, user: @current_user, gender: 'male')

    @other_user = create(:subscribing_user, email: 'alady@bar.com', password: 'a_password', firstname: 'Stephanie', lastname: 'Jango')
    @other_profile = create(:profile, user: @other_user, gender: 'female', birth_date: 33.years.ago, muddy_ratio: 80)
  end

  it 'does not show the full profile data if not singed in' do
    get profile_path(@other_profile), headers: json_headers

    expect(response).to have_http_status(403)
    expect(json_response['error']).to eq 'You must be signed in'
  end

  it 'shows the full profile data' do
    sign_in(@current_user.email, 'a_password')
    get profile_path(@other_profile), headers: json_headers

    expect(response).to have_http_status(200)
    expect(json_response['displayName']).to eq 'Stephanie Jango'
    expect(json_response['age']).to eq 33
    expect(json_response['gender']).to eq 'female'
    expect(json_response['muddy_ratio']).to eq 80
  end

  it 'does not show the full profile data for a profile that does not exist' do
    sign_in(@current_user.email, 'a_password')
    get profile_path(123_123), headers: json_headers

    expect(response).to have_http_status(500)
    expect(json_response['error']).to eq 'That profile does not exist'
  end
end
