class SysbenchResult < ApplicationRecord
  self.table_name = 'sysbench_results'
  self.primary_key = 'id'
  belongs_to :performance_test_run
end
