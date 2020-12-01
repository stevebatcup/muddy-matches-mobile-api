class Town < ApplicationRecord
  self.table_name = 'ref_towns'

  has_many :profiles
end
