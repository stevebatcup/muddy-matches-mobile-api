require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  include SpecHelpers

  before :all do
    create(:user_event_type, name: 'registration')
    create(:user_event_type, name: 'registration-form-error')
  end

  it 'does not register if user is already logged in' do
    signed_in_user = create(:user, email: 'exist@foo.com', password: 'foobar', firstname: 'Steve')

    sign_in(signed_in_user.email, 'foobar')
    post register_path, params: { firstname: 'Bobby' }, headers: json_headers

    expect(response).to have_http_status(403)
    expect(json_response['error']).to eq 'You are already signed in'
  end

  context 'does not register a new user with invalid data' do
    it 'returns a "missing data" error' do
      post register_path, params: bad_registration_params, headers: json_headers

      expect(response).to have_http_status(200)
      expect(json_response['errors']).to include 'Lastname can\'t be blank'
    end

    it 'returns a "bad data" error' do
      post register_path, params: bad_registration_params, headers: json_headers

      expect(json_response['errors']).to include 'Email is invalid'
    end

    it 'logs the registration error event' do
      post register_path, params: bad_registration_params, headers: json_headers

      log = UserEvent.last

      expect(log).to_not be_nil
      expect(log.event_type.name).to eq 'registration-form-error'
    end

    def bad_registration_params
      { user: { firstname: 'Mickey', email: 'foobar' }, profile: { dating_looking_for: 'male', gender: 'female' } }
    end
  end

  context 'register a new user' do
    it 'creates the user' do
      post register_path, params: registration_params, headers: json_headers

      expect(response).to have_http_status(200)
      expect(json_response['user']).to_not be_nil
    end

    it 'creates a profile for the user' do
      post register_path, params: registration_params, headers: json_headers

      expect(response).to have_http_status(200)
      expect(json_response['profile']).to_not be_nil

      profile_id = json_response['user']['profile_id']
      expect(json_response['profile']['id']).to eq profile_id
    end

    it 'logs the registration event' do
      post register_path, params: registration_params, headers: json_headers

      log = UserEvent.last

      expect(log).to_not be_nil
      expect(log.event_type.name).to eq 'registration'
      expect(log.user_id).to eq json_response['user']['id']
    end

    def registration_params
      {
        user:    {
          firstname: 'Mickey', lastname: 'Mouse', email: 'mickey@mouse.com', password: '123123'
        },
        profile: {
          dating_looking_for: 'male',
          gender:             'female'
        }
      }
    end
  end
end
