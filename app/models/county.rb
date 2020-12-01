class County < ApplicationRecord
  self.table_name = 'ref_counties'

  has_many :profiles
end
