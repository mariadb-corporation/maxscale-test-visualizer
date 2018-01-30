class Results < ApplicationRecord
  self.table_name = 'results'
  self.primary_key = 'id'
  belongs_to :test_run

  def self.result_for_test_and_test_run(test_name, test_run_id)
    find_by(test: test_name, id: test_run_id)
  end
end
