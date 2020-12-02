require 'rails_helper'

RSpec.describe 'Conversations', type: :request do
  include SpecHelpers

  before :all do
    @current_user = create(:subscribing_user, email: 'convo@bar.com', password: 'a_password', firstname: 'Steve')
    @current_profile = create(:profile, user: @current_user, gender: 'male')
    build_conversations
  end

  context 'when signed in' do
    before(:each) { sign_in(@current_user.email, 'a_password') }
    after(:each) { sign_out }

    it 'lists conversations for the current_user' do
      get conversations_path, headers: json_headers

      expect(response).to have_http_status(200)
      expect(genders).to include 'female'
      expect(display_names).to include 'Meggy'
    end

    it 'shows the most recently updated conversation first' do
      get conversations_path, headers: json_headers

      expect(conversations.first['converser']['displayName']).to eq 'Meggy'
    end

    it 'shows an excerpt of the most recent message in the conversation' do
      get conversations_path, headers: json_headers

      expect(conversations.first['lastMessage']['text']).to eq 'Oh my gosh!'
    end

    it 'paginates conversations' do
      get conversations_path(page: 2, per_page: 1), headers: json_headers

      expect(conversations.length).to eq 1
      expect(conversations.first['converser']['displayName']).to eq 'Janjanjan'
      expect(conversations.first['lastMessage']['text']).to eq 'Holy Mackerel'
    end

    it 'does not show the conversation data for a conversation that does not exist' do
      get conversation_path(123), headers: json_headers

      expect(response).to have_http_status(500)
      expect(json_response['error']).to eq 'That conversation does not exist'
    end

    it 'shows the conversation data' do
      build_detailed_conversation

      get conversation_path(@detailed_conversation), headers: json_headers

      expect(response).to have_http_status(200)
      expect(json_response['messages'].length).to eq 3
      expect(json_response['messages'][0]['sender']['displayName']).to eq 'Catalina Dietrich'
      expect(json_response['messages'][0]['body']).to eq 'Man this is cheesy!'
      expect(json_response['messages'][1]['sentAt']).to eq 2.days.ago.strftime('%b %d, %Y')
      expect(json_response['messages'][2]['recipient']['displayName']).to eq @current_user.profile.text_display_name
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
    before :all do
      @non_sub_user = create(:user, email: 'cheapskate@bar.com', password: 'a_password', firstname: 'Cheapskate')

      bella = create(:user, email: 'bella@bar.com', password: 'a_password', firstname: 'Bella', lastname: 'Mella')
      create(:profile, user: bella, gender: 'female')
      bella_msg = build(:message, body:                 'Oh my gosh!',
                                  sender_profile_id:    bella.profile.id,
                                  recipient_profile_id: @non_sub_user.profile.id)
      create(:conversation,
             profile_id_1: @non_sub_user.profile.id,
             profile_id_2: bella.profile.id,
             whos_turn:    bella.profile.id,
             modified:     1.day.ago,
             messages:     [bella_msg])
    end

    before(:each) { sign_in(@non_sub_user.email, 'a_password') }
    after(:each) { sign_out }

    it 'does not list conversations for a non-subscriber' do
      get conversations_path, headers: json_headers

      expect(response).to have_http_status(200)
      expect(display_names).to include 'Bella Mella'
      expect(conversations.first['lastMessage']['text']).to eq 'You must be a subscriber to read this message'
    end
  end

  private

  def conversations
    json_response['conversations'] if json_response['conversations'].present?
  end

  def display_names
    conversations.map { |c| c['converser']['displayName'] }
  end

  def genders
    conversations.map { |c| c['converser']['gender'] }
  end

  def build_conversations
    meg = create(:user, email: 'meg@bar.com', password: 'a_password', firstname: 'Meg')
    create(:approved_profile, user: meg, gender: 'female')
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
    create(:approved_profile, user: janet, gender: 'female')
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

  def build_detailed_conversation
    catalina = create(:user,
                      email:     'catalina@bar.com',
                      password:  'a_password',
                      firstname: 'Catalina',
                      lastname:  'Dietrich')
    create(:approved_profile, user: catalina, gender: 'female')
    msg1 = build(:message, body:                 'Hey there handsome!',
                           sender_profile_id:    catalina.profile.id,
                           recipient_profile_id: @current_user.profile.id,
                           sent:                 3.days.ago)
    msg2 = build(:message, body:                 'Hey yourself hotty!',
                           sender_profile_id:    @current_user.profile.id,
                           recipient_profile_id: catalina.profile.id,
                           sent:                 2.days.ago)
    msg3 = build(:message, body:                 'Man this is cheesy!',
                           sender_profile_id:    catalina.profile.id,
                           recipient_profile_id: @current_user.profile.id,
                           sent:                 1.day.ago)
    @detailed_conversation = create(:conversation,
                                    profile_id_1: @current_user.profile.id,
                                    profile_id_2: catalina.profile.id,
                                    whos_turn:    catalina.profile.id,
                                    modified:     1.day.ago,
                                    messages:     [msg1, msg2, msg3])
  end
end
