class ConnectDecision < ApplicationRecord
  belongs_to :user
  belongs_to :profile, foreign_key: :connect_profile_id
end
