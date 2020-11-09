class User < ApplicationRecord
  def password=(new_password)
    super(Digest::SHA1.hexdigest(new_password))
  end

  def authenticate(submitted_password)
    Digest::SHA1.hexdigest(submitted_password) == password
  end
end
