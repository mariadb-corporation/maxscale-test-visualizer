class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  # Convert the intervals of "1, 2, 3-5" (example) to the sql-query
  # "([field] = 1) OR ([field] = 2) OR ([field] BETWEEN 3 AND 5)"
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

  # Generate the sql-query for the field by the selected values
  # "[field] IN ('value_1', 'value_2')"
  def filter_field_to_sql(field, selected_filters_values, all_values_str)
    if selected_filters_values[field].nil? ||
        selected_filters_values[field].include?(all_values_str)
      ''
    else
      values_str_temp = selected_filters_values[field].join("', '")
      "(#{field.to_s} IN ('#{values_str_temp}'))"
    end
  end

  def field_with_version_to_sql(values, field_name, field_version_name, all_values_str)
    if values.nil? ||
        values.include?(all_values_str)
      ''
    else
      res = []
      values.each do |value|
        res << "(#{field_name} = '#{value.split(' ').first}' AND #{field_version_name} = '#{value.split(' ')[1..-1].join(' ')}')"
      end
      res.join(' OR ')
    end
  end

  # Generate the sql-query for the tests by the selected test names
  # "results.test IN ('test_1', 'test_2')"
  def filter_tests_to_sql(field, values)
    return '' if values.nil? || values.keys.empty?

    values_str_temp = values.keys.join("', '")
    "WHERE (#{field} IN ('#{values_str_temp}'))"
  end

  def time_interval_to_sql(field_name, start, finish)
    "(#{field_name} BETWEEN '#{start.to_time}' AND '#{finish.to_time}')"
  end

  # Generate the sql-query for the all filters by the selected values
  # "(mariadb_version IN (...)) AND (maxscale_source IN (...)) ..."
  def filters_to_sql(selected_filters_values)
    if !selected_filters_values[:use_sql_query].nil? && selected_filters_values[:use_sql_query] == 'true' &&
       !selected_filters_values[:sql_query].nil? && !selected_filters_values[:sql_query].empty?
      return selected_filters_values[:sql_query]
    end

    result = []

    mariadb_version = filter_field_to_sql(:mariadb_version, selected_filters_values, 'All')
    result << mariadb_version unless mariadb_version.empty?

    maxscale_source = filter_field_to_sql(:maxscale_source, selected_filters_values, 'All')
    result << maxscale_source unless maxscale_source.empty?

    box = filter_field_to_sql(:box, selected_filters_values, 'All')
    result << box unless box.empty?

    jenkins_id = ranges_string_to_sql('jenkins_id', selected_filters_values[:jenkins_build])
    result << jenkins_id unless jenkins_id.empty?

    dbms = field_with_version_to_sql(selected_filters_values[:dbms], 'product', 'mariadb_version', 'All')
    result << "(#{dbms})" unless dbms.empty?

    test_tool = field_with_version_to_sql(selected_filters_values[:test_tool], 'test_tool', 'test_tool_version', 'All')
    result << "(#{test_tool})" unless test_tool.empty?


    # time intervals
    if selected_filters_values[:filter_page] == 'TestRun'
      model = TestRun
    elsif selected_filters_values[:filter_page] == 'PerformanceTestRun'
      model = PerformanceTestRun
    end
    if selected_filters_values[:time_interval_dropdown] > 0
      time_interval_finish = model.last_date
      time_interval_start = model.last_date - selected_filters_values[:time_interval_dropdown].days
      result << time_interval_to_sql('start_time', time_interval_start, time_interval_finish)
    elsif selected_filters_values[:time_interval_dropdown] == 0 &&
          !selected_filters_values[:time_interval_start].nil? &&
          !selected_filters_values[:time_interval_finish].nil?
      time_interval_start = model.last_date
      time_interval_finish = model.last_date
      time_interval_start = selected_filters_values[:time_interval_start] unless selected_filters_values[:time_interval_start].empty?
      time_interval_finish = selected_filters_values[:time_interval_finish] unless selected_filters_values[:time_interval_finish].empty?

      result << time_interval_to_sql('start_time',
                                     time_interval_start,
                                     time_interval_finish)
    end

    if result.empty?
      return ''
    else
      return result.join(' AND ')
    end
  end

  def test_run_filters_to_sql(selected_filters_values)
    condition = filters_to_sql(selected_filters_values)
    unless condition.empty?
      condition = 'WHERE ' + condition
    end

    "SELECT * FROM test_run #{condition}"
  end

  # SQL-query for the table page with filtered test runs and tests
  def test_run_table_page_to_sql(selected_filters_values, test_runs_count, columns_count, page_num)
    limit, offset = calc_limit_and_offset(test_runs_count, columns_count, page_num)

    tests_filter = filter_tests_to_sql('results.test', selected_filters_values[:tests_names])

    filter_test_run_str =
        "SELECT results.test, results.result, results.core_dump_path, filter_test_run.* "\
      "FROM results "\
      "INNER JOIN "\
      "  (#{test_run_filters_to_sql(selected_filters_values)} ORDER BY start_time LIMIT #{limit} OFFSET #{offset}) "\
      "  as filter_test_run using(id) "\
      "#{tests_filter} "

    if !selected_filters_values[:hide_passed_tests].nil? && selected_filters_values[:hide_passed_tests] == 'true'
      hide_passed_tests_filter = ' WHERE (main_table.total_res > 0)'
    else
      hide_passed_tests_filter = ''
    end

    res =
        "SELECT * FROM "\
      "  (SELECT * FROM "\
      "    ( "\
      "      #{filter_test_run_str} "\
      "    ) as main_table "\
      "  INNER JOIN "\
      "    ( "\
      "      SELECT "\
      "        main_table_2.test as 'test', SUM(result) as total_res "\
      "      FROM "\
      "        ( "\
      "          #{filter_test_run_str} "\
      "        ) as main_table_2 "\
      "      GROUP BY main_table_2.test "\
      "    ) as total_res_table using(test)) as main_table "\
      "#{hide_passed_tests_filter} ORDER BY test;"

    res
  end

  # SQL-query for the test runs that are located on the table page
  def test_runs_on_page_sql(selected_filters_values, test_runs_count, columns_count, page_num)
    limit, offset = calc_limit_and_offset(test_runs_count, columns_count, page_num)
    "#{test_run_filters_to_sql(selected_filters_values)} ORDER BY start_time LIMIT #{limit} OFFSET #{offset}"
  end

  # Limit and offset for the sql-query for the test_runs that are located on the table page
  def calc_limit_and_offset(test_runs_count, columns_count, page_num)
    modulo = test_runs_count % columns_count

    if page_num == 1
      limit = modulo
      offset = 0
    else
      limit = columns_count
      offset = modulo + (page_num - 2) * columns_count
    end

    return limit, offset
  end

  def performance_test_run_filters_to_sql(selected_filters_values)
    condition = filters_to_sql(selected_filters_values)
    unless condition.empty?
      condition = 'WHERE ' + condition
    end

    res =
        "SELECT *"\
        "    FROM ( "\
        "      SELECT "\
      "            PTR.id, "\
        "          PTR.jenkins_id, "\
        "          PTR.start_time, "\
        "          PTR.box, "\
        "          PTR.product, "\
        "          PTR.mariadb_version, "\
        "          PTR.test_code_commit_id, "\
        "          PTR.job_name, "\
        "          PTR.machine_count, "\
        "          PTR.sysbench_params, "\
        "          PTR.mdbci_template, "\
        "          PTR.test_tool, "\
        "          PTR.test_tool_version, "\
        "          PTR.product_under_test, "\
        "          MP.target, "\
        "          MP.maxscale_commit_id, "\
        "          MP.maxscale_cnf, "\
        "          MP.maxscale_source, "\
        "          SR.OLTP_test_statistics_ignored_errors, "\
        "          SR.General_statistics_response_time_approx__95_percentile, "\
        "          SR.General_statistics_response_time_avg, "\
        "          SR.General_statistics_response_time_max, "\
        "          SR.General_statistics_response_time_min, "\
        "          SR.General_statistics_total_number_of_events, "\
        "          SR.General_statistics_total_time, "\
        "          SR.General_statistics_total_time_taken_by_event_execution, "\
        "          SR.OLTP_test_statistics_other_operations, "\
        "          SR.OLTP_test_statistics_queries_performed_other, "\
        "          SR.OLTP_test_statistics_queries_performed_read, "\
        "          SR.OLTP_test_statistics_queries_performed_total, "\
        "          SR.OLTP_test_statistics_queries_performed_write, "\
        "          SR.OLTP_test_statistics_read_write_requests, "\
        "          SR.OLTP_test_statistics_reconnects, "\
        "          SR.OLTP_test_statistics_transactions, "\
        "          SR.Threads_fairness_events_avg, "\
        "          SR.Threads_fairness_events_stddev, "\
        "          SR.Threads_fairness_execution_time_avg, "\
        "          SR.Threads_fairness_execution_time_stddev "\
        "      FROM "\
        "        performance_test_run AS PTR "\
        "      LEFT OUTER JOIN "\
        "        maxscale_parameters AS MP "\
        "      ON PTR.id = MP.id "\
        "      LEFT OUTER JOIN "\
        "        sysbench_results AS SR "\
        "      ON PTR.id = SR.id "\
        "    ) AS MAIN_TABLE "

    res + condition
  end

  def performance_test_run_table_page_to_sql(selected_filters_values, test_runs_count, columns_count, page_num)
    limit, offset = calc_limit_and_offset(test_runs_count, columns_count, page_num)
    res = performance_test_run_filters_to_sql(selected_filters_values) +
        " ORDER BY start_time LIMIT #{limit} OFFSET #{offset}; "
    res
  end

  def is_i?(str)
    str.to_i.to_s == str
  end
end
