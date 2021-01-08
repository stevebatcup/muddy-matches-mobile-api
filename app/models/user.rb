class User < ApplicationRecord
  validates_presence_of :firstname, :lastname, :password, :email
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates_uniqueness_of :email

  belongs_to :profile
  has_many :connect_decisions

  before_create :set_default_values
  after_create :set_extra_user_id
  validate :check_email_blacklist
  validate :check_email_wronglist

  class << self
    def timestamp_attributes_for_create
      super << 'created'
    end
  end

  def password=(new_password)
    super(encrypt_password(new_password))
  end

  def authenticate(submitted_password)
    encrypt_password(submitted_password) == password
  end

  def favourites
    profile.favourite_profiles.approved.mutually_unblocked(profile)
  end

  def fans
    profile.fan_profiles.approved.mutually_unblocked(profile)
  end

  def mutuals
    fans.to_a & favourites.to_a
  end

  def add_favourite(user)
    profile.add_favourite_profile(user.profile)
  end

  def unseen_messages
    profile.received_messages.unseen
  end

  def to_json_data
    {
      id:         id,
      profile_id: profile_id,
      firstName:  firstname,
      lastName:   lastname,
      email:      email
    }
  end

  def set_auth_token
    begin
      random_token = SecureRandom.hex(6)
    end while self.class.find_by(auth_token: random_token)
    self.auth_token = random_token
  end

  def subscriber?
    return false if subscription_expires.nil?

    subscription_expires >= Date.today
  end

  def setup_subscription(days)
    expires = if subscription_expires.nil?
                days.days.from_now
              else
                subscription_expires + days.days
              end
    update_attribute(:subscription_expires, expires)
  end

  def approve_connect(profile)
    return unless profile

    connect_decisions.create(
      connect_profile_id: profile.id,
      decision:           'yes'
    )
  end

  def reject_connect(profile)
    return unless profile

    connect_decisions.create(
      connect_profile_id: profile.id,
      decision:           'no'
    )
  end

  def approved_connects
    connect_decisions.where(decision: 'yes')
  end

  def rejected_connects
    connect_decisions.where(decision: 'no')
  end

  private

  def set_default_values
    self.last_active = Time.now
    set_auth_token
  end

  def set_extra_user_id
    update_attribute(:user_id, id)
  end

  def encrypt_password(pword)
    Digest::SHA1.hexdigest(pword)
  end

  def check_email_blacklist
    blacklisted = EmailBlacklistItem.find_by(email: email)
    errors.add(:email, I18n.t('activerecord.user.errors.cannot_register_now')) if blacklisted
  end

  def check_email_wronglist
    wronglisted = EmailWronglistItem.find_by(email: email)
    errors.add(:email, I18n.t('activerecord.user.errors.cannot_register_now')) if wronglisted
  end
end
