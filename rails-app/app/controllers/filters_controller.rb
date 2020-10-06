# Controller for the page with filters

class FiltersController < ApplicationController
  add_flash_types :error
  #before_action :authenticate_user

  DEFAULT_TEST_RUN_COUNT = 10

  #skip_before_action :verify_authenticity_token
  before_action :setup_selected_filters_values,
                only: [:test_results_for_test_runs,
                       :apply_test_run_filters,
                       :generate_sql_for_displaying_on_page,
                       :test_results_for_performance_test_runs,
                       :apply_performance_test_run_filters,
                       :qps_results_for_performance_test_runs,
                       :apply_performance_test_run_qps_filters,
                       :results_for_performance_test_runs_axes,
                       :apply_performance_test_run_axes_filters]

  def test_results_for_test_runs
    @selected_filters_values[:hide_passed_tests] = 'true'
    test_run_main_filter
    if params[:do_search] == 'true'
      make_test_run_query
    end
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

  # Performance test runs

  def test_results_for_performance_test_runs
    @mode = 'default'
    performance_test_run_main_filter
    make_performance_test_run_query
    @action_path = performance_test_run_path
  end

  def apply_performance_test_run_filters
    @mode = 'default'
    make_performance_test_run_query
    render json: {
        partial: render_to_string(partial: 'filters/performance_test_result_table', layout: false),
        page_num: @selected_filters_values[:page_num],
        table_columns_count: @selected_filters_values[:table_columns_count],
        table_pages_count: @selected_filters_values[:table_pages_count],
        total_count: @filtered_performance_test_runs_count,
        query_error: @query_error,
        flashes: render_to_string(partial: 'layouts/flashes', layout: false),
    }
  end

  # Performance test runs QPS

  def qps_results_for_performance_test_runs
    @mode = 'qps'
    performance_test_run_main_filter
    make_performance_test_run_query
    @action_path = performance_test_run_qps_path

    render 'filters/test_results_for_performance_test_runs'
  end

  def apply_performance_test_run_qps_filters
    @mode = 'qps'
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

  # Performance test run with axes

  def results_for_performance_test_runs_axes
    @mode = 'default'
    performance_test_run_axes_main_filter
    make_performance_test_run_axes_query
    @action_path = performance_test_run_axes_path
  end

  def apply_performance_test_run_axes_filters
    @mode = 'default'
    make_performance_test_run_axes_query
    render json: {
        partial: render_to_string(partial: 'filters/performance_test_axes_result_table', layout: false),
        page_num: @selected_filters_values[:page_num],
        table_columns_count: @selected_filters_values[:table_columns_count],
        table_pages_count: @selected_filters_values[:table_pages_count],
        total_count: @filtered_performance_test_runs_count,
        query_error: @query_error,
        flashes: render_to_string(partial: 'layouts/flashes', layout: false)
    }

  end

  # -----------------------

  def mdbci_template
    res = PerformanceTestRun.where('id' => params[:id]).first
    render plain: res['mdbci_template']
  end

  def maxscale_cnf
    res = MaxscaleParameter.where('id' => params[:id]).first
    render plain: res['maxscale_cnf']
  end

  private

  def test_run_main_filter
    @params = params

    # Values for the form elements
    @mariadb_version_options = TargetBuild.mariadb_version_values
    @maxscale_source_options = TargetBuild.maxscale_source_values
    @box_options = TargetBuild.box_values
    @test_options = TestCase.all.order(:name)
    @filter_page = 'TestRun'

    make_test_run_query
  end

  def make_test_run_query
    @query_error = false
    db = ActiveRecord::Base.establish_connection.connection

    begin
      filtered_test_runs = db.execute(test_run_filters_to_sql(@selected_filters_values))
      @filtered_test_runs_count = filtered_test_runs.count
    rescue StandardError
      @query_error = true
      flash.now[:error] = 'SQL query is invalid!'
    end

    if !@query_error && @filtered_test_runs_count > 0
      @selected_filters_values[:table_pages_count] = (@filtered_test_runs_count.to_f / @selected_filters_values[:table_columns_count].to_f).ceil
      if @selected_filters_values[:page_num] == -1
        @selected_filters_values[:page_num] = @selected_filters_values[:table_pages_count]
      end

      @test_results = db.exec_query(test_run_table_page_to_sql(@selected_filters_values,
                                                               @filtered_test_runs_count,
                                                               @selected_filters_values[:table_columns_count],
                                                               @selected_filters_values[:page_num]))
      @target_builds = db.exec_query(target_builds_on_page_sql(@selected_filters_values,
                                                               @filtered_test_runs_count,
                                                               @selected_filters_values[:table_columns_count],
                                                               @selected_filters_values[:page_num]))
      @test_runs = TestRun.where(target_build_id: @target_builds.map { |t| t['id'] })
      @tests_cases = TestCase.where(id: @test_results.map { |test_result| test_result['test_case_id'] }).order(:name)
    else
      @result_is_empty = true
      @tests_cases = []
      @target_builds = []
      @test_results = []
      @test_runs = []
    end
  end

  def performance_test_run_main_filter
    @params = params

    # Values for the form elements
    @maxscale_source_options = MaxscaleParameter.maxscale_source_values
    @dbms_options = PerformanceTestRun.dbms_values
    @test_tool_options = PerformanceTestRun.test_tool_values
    @maxscale_threads_options = MaxscaleParameter.maxscale_threads_values
    @sysbench_threads_options = PerformanceTestRun.sysbench_threads_values
    @filter_page = 'PerformanceTestRun'

    # make_performance_test_run_query
  end

  def make_performance_test_run_query()
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

      @test_results = []
      query_result.each(:as => :hash) do |row|
        begin
          row['QPS_read'] = (row['OLTP_test_statistics_queries_performed_read'] / row['General_statistics_total_time']).round(2)
          row['QPS_write'] = (row['OLTP_test_statistics_queries_performed_write'] / row['General_statistics_total_time']).round(2)
          row['QPS_other'] = (row['OLTP_test_statistics_queries_performed_other'] / row['General_statistics_total_time']).round(2)
          row['QPS_total'] = (row['OLTP_test_statistics_queries_performed_total'] / row['General_statistics_total_time']).round(2)
        rescue Exception => e
        end
        @test_results << row
      end

      if @mode == 'default'
        @tests_cases = ['OLTP_test_statistics_ignored_errors',
                        'General_statistics_response_time_approx__95_percentile',
                        'General_statistics_response_time_avg',
                        'General_statistics_response_time_max',
                        'General_statistics_response_time_min',
                        'General_statistics_total_number_of_events',
                        'General_statistics_total_time',
                        'OLTP_test_statistics_queries_performed_other',
                        'OLTP_test_statistics_queries_performed_read',
                        'OLTP_test_statistics_queries_performed_total',
                        'OLTP_test_statistics_queries_performed_write',
                        'OLTP_test_statistics_reconnects',
                        'OLTP_test_statistics_transactions',
                        'Threads_fairness_events_avg',
                        'Threads_fairness_events_stddev',
                        'Threads_fairness_execution_time_avg',
                        'Threads_fairness_execution_time_stddev']
      elsif @mode == 'qps'
        @tests_cases = ['QPS_read',
                        'QPS_write',
                        'QPS_other',
                        'QPS_total']
      end
    else
      @result_is_empty = true
      @tests_cases = []
      @test_results = []
    end
  end

  # Performance test run with axes

  def performance_test_run_axes_main_filter
    @params = params

    # Values for the form elements
    @maxscale_source_options = MaxscaleParameter.maxscale_source_values
    @dbms_options = PerformanceTestRun.dbms_values
    @test_tool_options = PerformanceTestRun.test_tool_values
    @maxscale_threads_options = MaxscaleParameter.maxscale_threads_values
    @sysbench_threads_options = PerformanceTestRun.sysbench_threads_values
    @filter_page = 'PerformanceTestRun'

    if @selected_filters_values[:x_axis_name].nil?
      @selected_filters_values[:x_axis_name] = 'maxscale_source'
    end
    if @selected_filters_values[:y_axis_name].nil?
      @selected_filters_values[:y_axis_name] = 'maxscale_threads'
    end
    if @selected_filters_values[:target_field].nil?
      @selected_filters_values[:target_field] = 'QPS_read'
    end
    if @selected_filters_values[:time_interval_dropdown].zero?
      @selected_filters_values[:time_interval_dropdown] = 5
    end
    if @selected_filters_values[:filter_page].nil?
      @selected_filters_values[:filter_page] = 'PerformanceTestRun'
    end
  end

  def make_performance_test_run_axes_query
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
      @test_results = []
      filtered_performance_test_runs.each(:as => :hash) do |row|
        begin
          row['QPS_read'] = (row['OLTP_test_statistics_queries_performed_read'] / row['General_statistics_total_time']).round(2)
          row['QPS_write'] = (row['OLTP_test_statistics_queries_performed_write'] / row['General_statistics_total_time']).round(2)
          row['QPS_other'] = (row['OLTP_test_statistics_queries_performed_other'] / row['General_statistics_total_time']).round(2)
          row['QPS_total'] = (row['OLTP_test_statistics_queries_performed_total'] / row['General_statistics_total_time']).round(2)
        rescue Exception => e
        end
        @test_results << row
      end
    else
      @result_is_empty = true
      @tests_cases = []
      @test_results = []
    end

    @tests_cases = ['QPS_read',
                    'QPS_write',
                    'QPS_other',
                    'QPS_total']
    @x_axis_name = @selected_filters_values[:x_axis_name] || 'maxscale_source'
    @y_axis_name = @selected_filters_values[:y_axis_name] || 'maxscale_threads'
    @x_axis_values = get_field_unique_values_from_array(@test_results, @x_axis_name)
    @x_axis_values.sort! { |a,b| a && b ? a <=> b : a ? -1 : 1 } unless @x_axis_values.nil?
    @y_axis_values = get_field_unique_values_from_array(@test_results, @y_axis_name)
    @y_axis_values.sort! { |a,b| a && b ? a <=> b : a ? -1 : 1 } unless @y_axis_values.nil?
    @target_field = @selected_filters_values[:target_field] || 'QPS_read'
  end

  def get_field_unique_values_from_array(array, field)
    array.map{ |k| k[field] }.uniq
  end

  # --------------

  def setup_selected_filters_values
    @selected_filters_values = {
        mariadb_version: params['mariadb_version'],
        maxscale_source: params['maxscale_source'],
        box: params['box'],
        run_id: params['run_id'],
        run_test_id: params['run_test_id'],
        test_cases: params['test_cases'],
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
        maxscale_threads: params['maxscale_threads'],
        sysbench_threads: params['sysbench_threads'],
        filter_page: params['filter_page'],
        x_axis_name: params['x_axis_dropdown'],
        y_axis_name: params['y_axis_dropdown'],
        target_field: params['target_field_dropdown']
    }

    if @selected_filters_values[:page_num].zero?
      @selected_filters_values[:page_num] = -1
    end

    if @selected_filters_values[:table_columns_count].zero?
      @selected_filters_values[:table_columns_count] = 10
    end
  end
end
