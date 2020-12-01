class MaritalStatus < ApplicationRecord
  self.table_name = 'ref_marital_status'

  has_many :profiles
end
