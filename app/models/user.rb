class User < ApplicationRecord
  belongs_to :profile

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

  private

  def encrypt_password(pword)
    Digest::SHA1.hexdigest(pword)
  end
end
