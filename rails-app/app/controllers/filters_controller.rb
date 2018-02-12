class FiltersController < ApplicationController
  rescue_from ActiveRecord::StatementInvalid, with: :sql_statement_invalid

  add_flash_types :error

  DEFAULT_TEST_RUN_COUNT = 10

  before_action :setup_selected_filters_values,
                only: :test_results_for_test_runs

  def test_results_for_test_runs

    @params = params

    # Values for the form elements
    @mariadb_version_options = TestRun.mariadb_version_values
    @maxscale_source_options = TestRun.maxscale_source_values
    @box_options = TestRun.box_values
    @test_options = Result.test_names

    if !@selected_filters_values[:use_sql_query].nil? && @selected_filters_values[:use_sql_query] == 'true'
      @test_runs = TestRun.where(@selected_filters_values[:sql_query])
    else
      filter_test_runs
    end

    cut_test_runs_for_table_page

    @test_run_ids = @test_runs.map(&:id)
    @tests_results = Result.where(id: @test_run_ids)

    if @selected_filters_values[:tests_names].nil? || @selected_filters_values[:tests_names].empty?
      @tests_names = @tests_results.select('test').group('test').map(&:test)
    else
      @tests_names = @selected_filters_values[:tests_names].keys
    end

    if !@selected_filters_values[:hide_passed_tests].nil? && @selected_filters_values[:hide_passed_tests] == 'true'
      @tests_names.keep_if do |test_name|
        @test_run_ids.any? do |test_run_id|
          test_res = @tests_results.result_for_test_and_test_run(test_name, test_run_id)
          !test_res.nil? && test_res.result == 1
        end
      end
    end
  end

  private

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
    }

    if @selected_filters_values[:page_num].zero?
      @selected_filters_values[:page_num] = -1
    end

    if @selected_filters_values[:table_columns_count].zero?
      @selected_filters_values[:table_columns_count] = 5
    end
  end

  def filter_collection_by_field(collection, selected_filters_values, field, all_values_str)
    if selected_filters_values[field].nil? ||
       selected_filters_values[field].include?(all_values_str)
      collection
    else
      collection.where(field => selected_filters_values[field])
    end
  end

  def filter_test_runs
    test_run_sql_range = ranges_string_to_sql('jenkins_id', @selected_filters_values[:jenkins_build])
    if @selected_filters_values[:jenkins_build].nil? || test_run_sql_range.empty?
      # Default
      @test_runs = TestRun.order('start_time')
    else
      # Filter by jenkins_id
      @test_runs = TestRun.where(test_run_sql_range)
    end

    @test_runs = filter_collection_by_field(@test_runs,
                                            @selected_filters_values,
                                            :mariadb_version, 'All')
    @test_runs = filter_collection_by_field(@test_runs,
                                            @selected_filters_values,
                                            :maxscale_source, 'All')
    @test_runs = filter_collection_by_field(@test_runs,
                                            @selected_filters_values,
                                            :box, 'All')
  end

  def cut_test_runs_for_table_page
    @selected_filters_values[:table_pages_count] = (@test_runs.count.to_f / @selected_filters_values[:table_columns_count].to_f).ceil
    if @selected_filters_values[:page_num] == -1
      @selected_filters_values[:page_num] = @selected_filters_values[:table_pages_count]
    end

    @test_runs = @test_runs.limit(@selected_filters_values[:table_columns_count]).offset((@selected_filters_values[:page_num] - 1) * @selected_filters_values[:table_columns_count])
  end

  def sql_statement_invalid
    flash.now[:error] = "SQL query is invalid."
    @tests_names = []
    @test_runs = []
    render :test_results_for_test_runs
  end
end
