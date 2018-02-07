class TestRun < ApplicationRecord
  self.table_name = 'test_run'
  self.primary_key = 'id'
  has_many :results

  def self.mariadb_version_values
    select('mariadb_version').group('mariadb_version')
  end

  def self.maxscale_source_values
    select('maxscale_source').group('maxscale_source')
  end

  def self.box_values
    select('box').group('box')
  end
end
