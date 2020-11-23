require 'rails_helper'
require 'support/helpers'

RSpec.describe 'Conversations', type: :request do
  include SpecHelpers

  before :all do
    @current_user = create(:user, email: 'convo@bar.com', password: 'a_password', firstname: 'Steve')
    @current_profile = create(:profile, user: @current_user, gender: 'male')
    build_conversations
  end

  context 'when signed in' do
    before(:each) { sign_in(@current_user.email, 'a_password') }

    it 'lists conversations for the current_user' do
      get conversations_path, headers: json_headers

      expect(response).to have_http_status(200)
      expect(genders).to include 'female'
      expect(display_names).to include 'Meggy'
    end

    it 'shows the most recently updated conversation first' do
      get conversations_path, headers: json_headers

      expect(conversations.first['displayName']).to eq 'Meggy'
    end

    it 'shows an excerpt of the most recent message in the conversation' do
      get conversations_path, headers: json_headers

      expect(conversations.first['lastMessage']['text']).to eq 'Oh my gosh!'
    end

    it 'paginates conversations' do
      get conversations_path(page: 2, per_page: 1), headers: json_headers

      expect(conversations.length).to eq 1
      expect(conversations.first['displayName']).to eq 'Janjanjan'
      expect(conversations.first['lastMessage']['text']).to eq 'Holy Mackerel'
    end
  end

  context 'when not signed in' do
    it 'does not list conversations' do
      get conversations_path, headers: json_headers

      expect(response).to have_http_status(403)
      expect(conversations).to be_nil
      expect(json_response['error']).to eq 'You must be signed in'
    end
  end

  context 'when not subscribed' do
    xit 'does not list conversations for a non-subscriber' do
      get conversations_path, headers: json_headers

      expect(response).to have_http_status(403)
      expect(conversations).to be_nil
      expect(json_response['error']).to eq 'You must be a subscriber'
    end
  end

  private

  def conversations
    json_response['conversations'] if json_response['conversations'].present?
  end

  def display_names
    conversations.map { |c| c['displayName'] }
  end

  def genders
    conversations.map { |c| c['gender'] }
  end

  def build_conversations
    meg = create(:user, email: 'meg@bar.com', password: 'a_password', firstname: 'Meg')
    create(:profile, user: meg, gender: 'female')
    create(:profile_text, type: 'display_name', content: 'Meggy', profile: meg.profile)
    meg_msg = build(:message, body:                 'Oh my gosh!',
                              sender_profile_id:    meg.profile.id,
                              recipient_profile_id: @current_user.profile.id)
    create(:conversation,
           profile_id_1: @current_user.profile.id,
           profile_id_2: meg.profile.id,
           whos_turn:    meg.profile.id,
           modified:     1.day.ago,
           messages:     [meg_msg])

    janet = create(:user, email: 'janet@bar.com', password: 'a_password', firstname: 'Janet')
    create(:profile, user: janet, gender: 'female')
    create(:profile_text, type: 'display_name', content: 'Janjanjan', profile: janet.profile)
    janet_msg = build(:message, body:                 'Holy Mackerel',
                                sender_profile_id:    janet.profile.id,
                                recipient_profile_id: @current_user.profile.id)
    create(:conversation,
           profile_id_1:    janet.profile.id,
           profile_id_2:    @current_user.profile.id,
           last_message_id: 2,
           whos_turn:       @current_user.profile.id,
           modified:        1.week.ago,
           messages:        [janet_msg])
  end
end