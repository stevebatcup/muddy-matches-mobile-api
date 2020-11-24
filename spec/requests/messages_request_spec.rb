require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  include SpecHelpers

  before :all do
    @current_user = create(:subscribing_user, email: 'sender@foo.com', password: 'a_password', firstname: 'Steve')
    @recipient = create(:user, email: 'recipient@foo.com', password: 'a_password', firstname: 'Miranda')

    @msg = build(:message, body:                 'Holy Mackerel',
                           sender_profile_id:    @recipient.profile.id,
                           recipient_profile_id: @current_user.profile.id)
    create(:conversation,
           profile_id_1: @recipient.profile.id,
           profile_id_2: @current_user.profile.id,
           modified:     1.week.ago,
           messages:     [@msg])
  end

  context 'when signed in' do
    before(:each) { sign_in(@current_user.email, 'a_password') }
    after(:each) { sign_out  }

    it 'raises an error when trying to send a message to a user who does not exist' do
      bad_message = { body: 'A message body blah blah', recipient_profile_id: '123_456' }

      expect do
        post messages_path, params: bad_message, headers: json_headers
      end.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'sends a message' do
      post messages_path, params: message_params, headers: json_headers

      expect(response).to have_http_status(200)
      expect(json_response['message']).to_not be_nil
      expect(json_response['message']['body']).to eq 'A message body blah blah'
      expect(@recipient.unseen_messages.length).to eq 1
    end

    it 'raises an error when trying to view a non-existent message' do
      expect do
        get message_path(123), headers: json_headers
      end.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'shows a message' do
      get message_path(@msg), headers: json_headers

      expect(response).to have_http_status(200)
      expect(json_response['message']).to_not be_nil
      expect(json_response['message']['body']).to eq 'Holy Mackerel'
    end
  end

  context 'when not signed in' do
    it 'does not send a message' do
      post messages_path, params: message_params, headers: json_headers

      expect(response).to have_http_status(403)
      expect(json_response['error']).to eq 'You must be signed in'
    end

    it 'does not show a message' do
      get message_path(@msg), headers: json_headers

      expect(response).to have_http_status(403)
      expect(json_response['error']).to eq 'You must be signed in'
    end
  end

  context 'when not subscribed' do
    before :all do
      @cheapskate = create(:user, email: 'cheapskate@foo.com', password: 'a_password', firstname: 'Cheapskate')
      buffy = create(:user, email: 'recipient@foo.com', password: 'a_password', firstname: 'Buffy')

      msg = build(:message, body:                 'Holy Mackerel',
                            sender_profile_id:    buffy.profile.id,
                            recipient_profile_id: @cheapskate.profile.id)
      create(:conversation,
             profile_id_1: buffy.profile.id,
             profile_id_2: @cheapskate.profile.id,
             modified:     1.week.ago,
             messages:     [msg])
    end

    before(:each) { sign_in(@cheapskate.email, 'a_password') }
    after(:each) { sign_out }

    it 'does not send a message' do
      post messages_path, params: message_params, headers: json_headers

      expect(response).to have_http_status(403)
      expect(json_response['error']).to eq 'You must be a subscriber to send a message'
    end

    it 'shows a restricted message' do
      get message_path(@msg), headers: json_headers

      expect(response).to have_http_status(200)
      expect(json_response['message']['body']).to eq 'You must be a subscriber to read this message'
    end
  end

  def message_params
    { body: 'A message body blah blah', recipient_profile_id: @recipient.profile.id }
  end
end
