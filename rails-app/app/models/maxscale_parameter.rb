class MaxscaleParameter < ApplicationRecord
  self.table_name = 'maxscale_parameters'
  self.primary_key = 'id'
  belongs_to :performance_test_run

  def self.maxscale_source_values
    select('maxscale_source').group('maxscale_source')
  end
end
