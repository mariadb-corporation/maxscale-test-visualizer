class PerformanceTestRun < ApplicationRecord
  self.table_name = 'performance_test_run'
  self.primary_key = 'id'
  has_many :sysbench_results
  has_many :maxscale_parameters

  def self.dbms_values
    query = select('product, mariadb_version').group('product, mariadb_version')
    res = []
    query.each do |row|
      res << "#{row['product']}, #{row['mariadb_version']}"
    end
    res
  end

  def self.test_tool_values
    query = select('test_tool, test_tool_version').group('test_tool, test_tool_version')
    res = []
    query.each do |row|
      res << "#{row['test_tool']}, #{row['test_tool_version']}"
    end
    res
  end

  def self.sysbench_threads_values
    query = select('sysbench_threads').group('sysbench_threads')
  end

  def self.last_date
    select('start_time').order(start_time: :desc).first.start_time
  end
end
