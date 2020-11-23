require 'rails_helper'

RSpec.describe Conversation, type: :model do
  before :all do
    @user1 = create(:user, email: 'user1@foo.com', password: 'password')
    @user2 = create(:user, email: 'user2@foo.com', password: 'password')
    @user3 = create(:user, email: 'user3@foo.com', password: 'password')
  end

  def create_conversation
    message = build(:message, body:                 'An ice breaking message',
                              sender_profile_id:    @user1.profile.id,
                              recipient_profile_id: @user2.profile.id)
    @conversation = create(:conversation,
                           profile_id_1:    @user1.profile.id,
                           profile_id_2:    @user2.profile.id,
                           last_message_id: 0,
                           whos_turn:       @user2.profile.id,
                           messages:        [message],
                           modified:        1.week.ago)
  end

  it 'finds the conversation between 2 users given user1 before user2' do
    create_conversation

    conversation = Conversation.find_between(@user1, @user2)

    expect(conversation).to_not be_nil
    expect(conversation.messages.last.body).to eq 'An ice breaking message'
  end

  it 'finds the conversation between 2 users given user2 before user1' do
    create_conversation

    conversation = Conversation.find_between(@user2, @user1)

    expect(conversation).to_not be_nil
    expect(conversation.messages.last.body).to eq 'An ice breaking message'
  end

  it 'creates a new conversation between 2 users if one does not already exist' do
    conversation = Conversation.find_between(@user1, @user3)
    expect(conversation).to be_nil

    new_conversation = Conversation.build_between(@user3, @user1)
    expect(new_conversation).to_not be_nil
    expect(new_conversation.profile_id_1).to eq @user3.profile.id
    expect(new_conversation.profile_id_2).to eq @user1.profile.id
  end

  it 'sets default values on a conversation' do
    message = build(:message, body:                 'Another ice breaking message',
                              sender_profile_id:    @user3.profile.id,
                              recipient_profile_id: @user1.profile.id)
    new_conversation = Conversation.build_between(@user3, @user1)
    new_conversation.messages << message
    new_conversation.save

    expect(new_conversation.whos_turn).to eq @user1.profile.id
    expect(new_conversation.message_count).to eq 1
    expect(new_conversation.last_message_is_question).to eq 0
  end

  it 'updates the conversation last_message_id after saving' do
    message = build(:message, body:                 'Another ice breaking message',
                              sender_profile_id:    @user3.profile.id,
                              recipient_profile_id: @user1.profile.id)
    new_conversation = Conversation.build_between(@user3, @user1)
    new_conversation.messages << message
    new_conversation.save

    expect(new_conversation.last_message_id).to eq message.reload.id
  end

  context 'validation' do
    it 'must have at least 1 message before saving' do
      new_conversation = Conversation.build_between(@user3, @user1)
      new_conversation.valid?

      expect(new_conversation.errors).to_not be_empty
      expect(new_conversation.errors['messages']).to include 'Must have at least one message'
    end
  end
end
