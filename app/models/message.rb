class Message < ApplicationRecord
  belongs_to  :conversation
  belongs_to :receiving_profile, class_name: 'Profile', foreign_key: :recipient_profile_id

  after_create :update_conversation_last_message_id
  before_create :set_default_attributes

  class << self
    def unseen
      where(recipient_msg_status: 'active', recipient_msg_read: 'no')
    end

    private

    def timestamp_attributes_for_create
      super << 'sent'
    end
  end

  def update_conversation_last_message_id
    conversation.update_attribute(:last_message_id, id)
  end

  def read?
    read_on.present? && recipient_msg_read == 'yes'
  end

  private

  def set_default_attributes
    self.origin = 'mobile app'
    self.recipient_msg_read = 'no'
    self.message_type = 'standard'
    self.sender_msg_status = 'active'
    self.recipient_msg_status = 'active'
  end
end
