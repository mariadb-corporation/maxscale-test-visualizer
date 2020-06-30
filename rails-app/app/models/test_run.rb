class TestRun < ApplicationRecord
  self.table_name = 'test_run'
  self.primary_key = 'id'
  has_many :results

  def self.last_date
    select('start_time').order(start_time: :desc).first.start_time
  end
end
