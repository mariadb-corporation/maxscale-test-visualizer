# Controller for the page with filters

class FiltersController < ApplicationController
  add_flash_types :error

  DEFAULT_TEST_RUN_COUNT = 10

  skip_before_action :verify_authenticity_token
  before_action :setup_selected_filters_values,
                only: [:test_results_for_test_runs, :apply_test_run_filters, :generate_sql_for_displaying_on_page, :test_results_for_performance_test_runs, :apply_performance_test_run_filters]

  def test_results_for_test_runs
    @selected_filters_values[:hide_passed_tests] = 'true'
    test_run_main_filter
  end

  def apply_test_run_filters
    make_test_run_query
    render json: {
      partial: render_to_string(partial: 'filters/result_table', layout: false),
      page_num: @selected_filters_values[:page_num],
      table_columns_count: @selected_filters_values[:table_columns_count],
      table_pages_count: @selected_filters_values[:table_pages_count],
      total_count: @filtered_test_runs_count,
      query_error: @query_error,
      flashes: render_to_string(partial: 'layouts/flashes', layout: false)
    }
  end

  def generate_sql_for_displaying_on_page
    query = filters_to_sql(@selected_filters_values)
    render json: { sql_query: query }
  end

  # Perfomance test runs

  def test_results_for_performance_test_runs
    performance_test_run_main_filter
  end

  def apply_performance_test_run_filters
    make_performance_test_run_query
    render json: {
        partial: render_to_string(partial: 'filters/performance_test_result_table', layout: false),
        page_num: @selected_filters_values[:page_num],
        table_columns_count: @selected_filters_values[:table_columns_count],
        table_pages_count: @selected_filters_values[:table_pages_count],
        total_count: @filtered_performance_test_runs_count,
        query_error: @query_error,
        flashes: render_to_string(partial: 'layouts/flashes', layout: false)
    }
  end

  def mdbci_template
    res = PerformanceTestRun.where('jenkins_id' => params[:jenkins_id]).first
    render plain: res['mdbci_template']
  end

  def maxscale_cnf
    id = PerformanceTestRun.where('jenkins_id' => params[:jenkins_id]).first['id']
    res = MaxscaleParameter.where('id' => id).first
    render plain: res['maxscale_cnf']
  end

  private

  def test_run_main_filter
    @params = params

    # Values for the form elements
    @mariadb_version_options = TestRun.mariadb_version_values
    @maxscale_source_options = TestRun.maxscale_source_values
    @box_options = TestRun.box_values
    @test_options = Result.test_names
    @filter_page = 'TestRun'

    make_test_run_query
  end

  def make_test_run_query
    @query_error = false

    db = ActiveRecord::Base.establish_connection.connection

    begin
      filtered_test_runs = db.execute(test_run_filters_to_sql(@selected_filters_values))
      @filtered_test_runs_count = filtered_test_runs.count
    rescue Exception => e
      @query_error = true
      flash.now[:error] = 'SQL query is invalid!'
    end

    if !@query_error && @filtered_test_runs_count > 0
      @selected_filters_values[:table_pages_count] = (filtered_test_runs.count.to_f / @selected_filters_values[:table_columns_count].to_f).ceil
      if @selected_filters_values[:page_num] == -1
        @selected_filters_values[:page_num] = @selected_filters_values[:table_pages_count]
      end

      query_result = db.execute(test_run_table_page_to_sql(@selected_filters_values, filtered_test_runs.count, @selected_filters_values[:table_columns_count], @selected_filters_values[:page_num]))
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
    else
      @result_is_empty = true
      @tests_names = []
      @test_runs = []
      @final_result = []
    end
  end

  def performance_test_run_main_filter
    @params = params

    # Values for the form elements
    @maxscale_source_options = MaxscaleParameter.maxscale_source_values
    @dbms_options = PerformanceTestRun.dbms_values
    @test_tool_options = PerformanceTestRun.test_tool_values
    @filter_page = 'PerformanceTestRun'

    make_performance_test_run_query
  end

  def make_performance_test_run_query
    @query_error = false

    db = ActiveRecord::Base.establish_connection.connection

    begin
      filtered_performance_test_runs = db.execute(performance_test_run_filters_to_sql(@selected_filters_values))
      @filtered_performance_test_runs_count = filtered_performance_test_runs.count
    rescue Exception => e
      @query_error = true
      flash.now[:error] = 'SQL query is invalid!'
    end

    if !@query_error && @filtered_performance_test_runs_count > 0
      @selected_filters_values[:table_pages_count] = (filtered_performance_test_runs.count.to_f / @selected_filters_values[:table_columns_count].to_f).ceil
      if @selected_filters_values[:page_num] == -1
        @selected_filters_values[:page_num] = @selected_filters_values[:table_pages_count]
      end

      query_result = db.execute(performance_test_run_table_page_to_sql(@selected_filters_values, filtered_performance_test_runs.count, @selected_filters_values[:table_columns_count], @selected_filters_values[:page_num]))
      # test_runs_on_page = db.execute(test_runs_on_page_sql(@selected_filters_values, filtered_test_runs.count, @selected_filters_values[:table_columns_count], @selected_filters_values[:page_num]))

      @final_result = []
      query_result.each(:as => :hash) do |row|
        @final_result << row
      end

      @tests_names = ['OLTP_test_statistics_ignored_errors',
                      'General_statistics_response_time_approx__95_percentile',
                      'General_statistics_response_time_avg',
                      'General_statistics_response_time_max',
                      'General_statistics_response_time_min',
                      'General_statistics_total_number_of_events',
                      'General_statistics_total_time',
                      'General_statistics_total_time_taken_by_event_execution',
                      'OLTP_test_statistics_other_operations',
                      'OLTP_test_statistics_queries_performed_other',
                      'OLTP_test_statistics_queries_performed_read',
                      'OLTP_test_statistics_queries_performed_total',
                      'OLTP_test_statistics_queries_performed_write',
                      'OLTP_test_statistics_read_write_requests',
                      'OLTP_test_statistics_reconnects',
                      'OLTP_test_statistics_transactions',
                      'Threads_fairness_events_avg',
                      'Threads_fairness_events_stddev',
                      'Threads_fairness_execution_time_avg',
                      'Threads_fairness_execution_time_stddev']
    else
      @result_is_empty = true
      @tests_names = []
      @final_result = []
    end
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
        table_columns_count: params['table_columns_count'].to_i,
        time_interval_dropdown: params['time_interval_dropdown'].to_i,
        time_interval_start: params['time_interval_start'],
        time_interval_finish: params['time_interval_finish'],
        dbms: params['dbms'],
        test_tool: params['test_tool'],
        filter_page: params['filter_page']
    }

    if @selected_filters_values[:page_num].zero?
      @selected_filters_values[:page_num] = -1
    end

    if @selected_filters_values[:table_columns_count].zero?
      @selected_filters_values[:table_columns_count] = 20
    end
  end
end
