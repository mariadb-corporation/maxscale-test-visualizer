class TargetBuild < ApplicationRecord
  self.table_name = 'target_builds'
  self.primary_key = 'id'
  has_many :results
end