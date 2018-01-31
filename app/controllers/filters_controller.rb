class FiltersController < ApplicationController
  DEFAULT_TEST_RUN_COUNT = 10

  def test_results_for_test_runs
    # Values for the form elements
    @mariadb_versions = TestRun.select('mariadb_version').group('mariadb_version')
    @maxscale_sources = TestRun.select('maxscale_source').group('maxscale_source')
    @boxes = TestRun.select('box').group('box')
    @tests = Results.select('test').group('test')

    # Filters
    @filters_selects = Hash.new
    @filters_selects['mariadb_version'] = params['mariadb_version']
    @filters_selects['maxscale_source'] = params['maxscale_source']
    @filters_selects['box'] = params['box']
    @filters_selects['jenkins_build'] = params['jenkins_build']
    @filters_selects['tests_names'] = params['tests_names']

    # --------
    if @filters_selects['jenkins_build'].nil? || (ranges_string_to_sql('jenkins_id', @filters_selects['jenkins_build']).empty?)
      # Default
      @last_test_runs = TestRun.order('start_time DESC').limit(DEFAULT_TEST_RUN_COUNT)
      @last_test_runs = @last_test_runs.order('start_time')
    else
      # Filter by jenkins_id
      @last_test_runs = TestRun.where(ranges_string_to_sql('jenkins_id', @filters_selects['jenkins_build']))
    end


    if !@filters_selects['mariadb_version'].nil? && !@filters_selects['mariadb_version'].include?('All')
      @last_test_runs = @last_test_runs.where(mariadb_version: @filters_selects['mariadb_version'])
    end

    if !@filters_selects['maxscale_source'].nil? && !@filters_selects['maxscale_source'].include?('All')
      @last_test_runs = @last_test_runs.where(maxscale_source: @filters_selects['maxscale_source'])
    end

    if !@filters_selects['box'].nil? && !@filters_selects['box'].include?('All')
      @last_test_runs = @last_test_runs.where(box: @filters_selects['box'])
    end
    # --------

    # @last_test_runs = @last_test_runs.reverse

    @test_run_ids = []
    @last_test_runs.each { |test_run_item| @test_run_ids << test_run_item.id }
    @tests_results = Results.where(id: @test_run_ids)

    if @filters_selects['tests_names'].nil? || (!@filters_selects['tests_names'].nil? && @filters_selects['tests_names'].empty?)
      @tests_names_query = @tests_results.select('test').group('test')
      @tests_names = []
      @tests_names_query.each do |test_name|
        @tests_names << test_name.test
      end
    else
      @tests_names = @filters_selects['tests_names']
    end

  end

  private

  def ranges_string_to_sql(field, ranges_string)
    return '' if ranges_string.nil?

    result = []
    ranges = ranges_string.delete(' ').split(',')
    return '' if ranges.nil? || ranges.empty?

    ranges.each do |range|
      if range.include?('-')
        range_values = range.split('-')
        if range_values.size == 2 && is_i?(range_values[0]) && is_i?(range_values[1])
          left_value = [range_values[0].to_i, range_values[1].to_i].min
          right_value = [range_values[0].to_i, range_values[1].to_i].max
          result << " (#{field} BETWEEN '#{left_value}' AND '#{right_value}')"
        end
      elsif is_i?(range)
        result << " (#{field} = #{range.to_i})"
      end
    end
    result.join(' OR')
  end

  def is_i?(str)
    str.to_i.to_s == str
  end
end
