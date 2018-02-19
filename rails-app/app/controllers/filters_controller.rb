# Controller for the page with filters

class FiltersController < ApplicationController
  rescue_from ActiveRecord::StatementInvalid, with: :sql_statement_invalid

  add_flash_types :error

  DEFAULT_TEST_RUN_COUNT = 10

  skip_before_action :verify_authenticity_token
  before_action :setup_selected_filters_values,
                only: [:test_results_for_test_runs, :apply_filters]

  def test_results_for_test_runs
    main_filter
  end

  def apply_filters
    main_filter
    render :test_results_for_test_runs
  end

  private

  def main_filter
    @params = params

    # Values for the form elements
    @mariadb_version_options = TestRun.mariadb_version_values
    @maxscale_source_options = TestRun.maxscale_source_values
    @box_options = TestRun.box_values
    @test_options = Result.test_names

    db = ActiveRecord::Base.establish_connection.connection

    filtered_test_runs = db.execute(test_run_filters_to_sql(@selected_filters_values))
    @filtered_test_runs_count = filtered_test_runs.count

    @selected_filters_values[:table_pages_count] = (filtered_test_runs.count.to_f / @selected_filters_values[:table_columns_count].to_f).ceil
    if @selected_filters_values[:page_num] == -1
      @selected_filters_values[:page_num] = @selected_filters_values[:table_pages_count]
    end

    query_result = db.execute(table_page_to_sql(@selected_filters_values, filtered_test_runs.count, @selected_filters_values[:table_columns_count], @selected_filters_values[:page_num]))
    test_runs_on_page = db.execute(test_runs_on_page_sql(@selected_filters_values, filtered_test_runs.count, @selected_filters_values[:table_columns_count], @selected_filters_values[:page_num]))

    @final_result = []
    query_result.each(:as => :hash) do |row|
      @final_result << row
    end

    @test_runs = []
    test_runs_on_page.each(:as => :hash) do |row|
      @test_runs << row
    end

    @tests_names = @final_result.collect { |row| row['test'] }.uniq
  end

  def setup_selected_filters_values
    @selected_filters_values = {
        mariadb_version: params['mariadb_version'],
        maxscale_source: params['maxscale_source'],
        box: params['box'],
        jenkins_build: params['jenkins_build'],
        tests_names: params['tests_names'],
        hide_passed_tests: params['hide_passed_tests'],
        use_sql_query: params['use_sql_query'],
        sql_query: params['sql_query'],
        page_num: params['page_num'].to_i,
        table_columns_count: params['table_columns_count'].to_i
    }

    if @selected_filters_values[:page_num].zero?
      @selected_filters_values[:page_num] = -1
    end

    if @selected_filters_values[:table_columns_count].zero?
      @selected_filters_values[:table_columns_count] = 20
    end
  end

  def sql_statement_invalid
    flash.now[:error] = 'SQL query is invalid or query result is empty.'
    @tests_names = []
    @test_runs = []
    render :test_results_for_test_runs
  end
end
