class Conversation < ApplicationRecord
  has_many :messages

  validates :messages, length: { minimum: 1, message: 'Must have at least one message' }

  before_save :set_missing_values

  class << self
    def list_for_user(user, page = 1, per_page = 10)
      where(profile_id_1: user.profile.id)
        .or(where(profile_id_2: user.profile.id))
        .order(modified: :desc)
        .page(page).per(per_page)
    end

    def find_between(user1, user2)
      results = where(profile_id_1: user1.profile.id, profile_id_2: user2.profile.id)
                .or(where(profile_id_2: user1.profile.id, profile_id_1: user2.profile.id))

      return if results.nil?

      results.first
    end

    def build_between(user1, user2)
      new(
        profile_id_1: user1.profile.id,
        profile_id_2: user2.profile.id
      )
    end

    def find_or_build_between(user1, user2)
      find_between(user1, user2) || build_between(user1, user2)
    end

    private

    def timestamp_attributes_for_create
      super << 'created'
    end

    def timestamp_attributes_for_update
      super << 'modified'
    end
  end

  def set_missing_values
    self.whos_turn = messages.last.sender_profile_id == profile_id_1 ? profile_id_2 : profile_id_1
    self.last_message_id = 0 if last_message_id.nil?
    self.message_count = messages.size
    self.last_message_is_question = false
  end

  def other_profile(profile)
    id = profile.id == profile_id_1 ? profile_id_2 : profile_id_1
    Profile.find(id)
  end

  def last_message
    Message.find(last_message_id)
  end
end
