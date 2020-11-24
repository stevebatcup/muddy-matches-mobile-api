class Profile < ApplicationRecord
  self.table_name = 'published_profiles'
  self.primary_key = 'profile_id'

  validates_associated :user
  validates_presence_of :gender, :dating_looking_for

  has_one :user
  has_many :profile_texts

  before_create :set_default_data
  after_create :set_default_display_name

  # messages I have recieved
  has_many :received_messages, class_name: 'Message', foreign_key: :recipient_profile_id

  # people I have favourited
  has_many	:favouritisations, -> { where(favouriter_status: :active) },
           class_name:  'Favourite',
           foreign_key: :profile_id
  has_many :favourite_profiles, through: :favouritisations

  # people who have favourited me
  has_many	:fandoms, -> { where(favourited_status: :active) },
           class_name:  'Favourite',
           foreign_key: :favourite_profile_id
  has_many :fan_profiles, through: :fandoms, source: :profile

  # people I have blocked
  has_many	:blockations,
           class_name:  'Block',
           foreign_key: :profile_id
  has_many :blocked_profiles, through: :blockations

  # people who have blocked me
  has_many	:blockings,
           class_name:  'Block',
           foreign_key: :blocked_profile_id
  has_many :blocking_profiles, through: :blockings, source: :profile

  class << self
    def build_default(params)
      new(dating_looking_for: params[:dating_looking_for], gender: params[:gender])
    end

    def approved
      joins(:user).where.not(users: { status: %w[deleted removed] })
                  .where(publish_status: 'approved')
    end

    def unblocked(profile)
      where.not(profile_id: profile.blockations.map(&:blocked_profile_id))
    end

    def unblocking(profile)
      where.not(profile_id: profile.blockings.map(&:profile_id))
    end

    def mutually_unblocked(profile)
      unblocked(profile).unblocking(profile)
    end

    private

    def timestamp_attributes_for_create
      super << 'created'
    end

    def timestamp_attributes_for_update
      super << 'stamp'
    end
  end

  def visible_and_approved?
    visibility_status == 'visible' && publish_status == 'approved'
  end

  def add_favourite_profile(profile)
    favouritisations << Favourite.new({
                                        favourite_profile_id: profile.id,
                                        favouriter_status:    :active,
                                        favourited_status:    :active,
                                        created:              Time.now
                                      })
    save
  end

  def block(profile)
    blockations << Block.new({
                               blocked_profile_id: profile.id,
                               status:             :active,
                               created:            Time.now
                             })
    save
  end

  def text_display_name
    item = profile_texts.find_by(type: 'display_name', status: :approved)
    item = profile_texts.find_by(type: 'display_name', status: :pending) if item.nil?
    return if item.nil?

    item.content
  end

  def to_json_data
    {
      id: id
    }
  end

  def set_default_display_name
    return unless user

    name = "#{user.firstname} #{user.lastname}"
    profile_texts.create(type: 'display_name', status: :pending, content: name)
  end

  private

  def set_default_data
    self.dating = 'yes'
    self.profile_status = 'new' if profile_status.nil?
    self.publish_status = 'new' if publish_status.nil?
  end
end
