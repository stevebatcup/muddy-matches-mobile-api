require 'rails_helper'

RSpec.describe Message, type: :model do
  before :all do
    @user1 = create(:user, email: 'user1@foo.com', password: 'password')
    @user2 = create(:user, email: 'user2@foo.com', password: 'password')

    @message = build(:message, body:                 'Another ice breaking message',
                               sender_profile_id:    @user1.profile.id,
                               recipient_profile_id: @user2.profile.id)
    @new_conversation = Conversation.build_between(@user1, @user2)
    @new_conversation.messages << @message
  end

  it 'updates the conversation last_message_id' do
    @new_conversation.save
    @message.update_conversation_last_message_id

    expect(@new_conversation.reload.last_message_id).to eq @message.id
  end

  it 'sets the default values on creation' do
    @new_conversation.save

    expect(@message.origin).to eq 'mobile app'
    expect(@message.subject).to be_nil
    expect(@message.sent).to be < Time.now
    expect(@message.recipient_msg_read).to eq 'no'
    expect(@message.read_on).to be_nil
    expect(@message.sender_msg_status).to eq 'active'
    expect(@message.recipient_msg_status).to eq 'active'
    expect(@message.message_type).to eq 'standard'
  end
end
