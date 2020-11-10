class Profile < ApplicationRecord
  self.table_name = 'published_profiles'
  self.primary_key = 'profile_id'

  has_one :user

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

  def self.approved
    joins(:user).where.not(users: { status: %w[deleted removed] })
                .where(publish_status: 'approved')
  end

  def self.unblocked(profile)
    where.not(profile_id: profile.blockations.map(&:blocked_profile_id))
  end

  def self.unblocking(profile)
    where.not(profile_id: profile.blockings.map(&:profile_id))
  end

  def self.mutually_unblocked(profile)
    unblocked(profile).unblocking(profile)
  end
end
