class FiltersController < ApplicationController
  DEFAULT_TEST_RUN_COUNT = 10

  def test_names_and_test_runs
    @last_test_runs = TestRun.order('start_time DESC').limit(DEFAULT_TEST_RUN_COUNT).reverse

    @test_runs_ids = []
    @last_test_runs.each { |test_run_item| @test_runs_ids << test_run_item.id }

    @tests_results = Results.where(id: @test_runs_ids)

    @tests_names = @tests_results.select('test').group('test')
  end
end
