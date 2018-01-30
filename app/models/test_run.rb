class TestRun < ApplicationRecord
  self.table_name = 'test_run'
  self.primary_key = 'id'
  has_many :results
end
