class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

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

  def filter_field_to_sql(field, selected_filters_values, all_values_str)
    if selected_filters_values[field].nil? ||
        selected_filters_values[field].include?(all_values_str)
      ''
    else
      values_str_temp = selected_filters_values[field].join("', '")
      "(#{field.to_s} IN ('#{values_str_temp}'))"
    end
  end

  def filter_tests_to_sql(field, values)
    return '' if values.nil? || values.keys.empty?

    values_str_temp = values.keys.join("', '")
    "WHERE (#{field} IN ('#{values_str_temp}'))"
  end

  def filters_to_sql(selected_filters_values)
    if !selected_filters_values[:use_sql_query].nil? && selected_filters_values[:use_sql_query] == 'true'
      return 'WHERE '.concat(selected_filters_values[:sql_query])
    end

    result = []

    mariadb_version = filter_field_to_sql(:mariadb_version, selected_filters_values, 'All')
    result << mariadb_version unless mariadb_version.empty?

    maxscale_source = filter_field_to_sql(:maxscale_source, selected_filters_values, 'All')
    result << maxscale_source unless maxscale_source.empty?

    box = filter_field_to_sql(:box, selected_filters_values, 'All')
    result << box unless box.empty?

    jenkins_id = ranges_string_to_sql('jenkins_id', @selected_filters_values[:jenkins_build])
    result << jenkins_id unless jenkins_id.empty?

    if result.empty?
      return ''
    else
      return 'WHERE '.concat(result.join(' AND '))
    end
  end

  def test_run_filters_to_sql(selected_filters_values)
    "(SELECT * FROM test_run #{filters_to_sql(selected_filters_values)})"
  end

  def table_page_to_sql(selected_filters_values, test_runs_count, columns_count, page_num)
    limit, offset = calc_limit_and_offset(test_runs_count, columns_count, page_num)

    tests_filter = filter_tests_to_sql('results.test', selected_filters_values[:tests_names])

    filter_test_run_str =
        "SELECT results.test, results.result, filter_test_run.* "\
      "FROM results "\
      "INNER JOIN "\
      "  (SELECT * FROM test_run #{filters_to_sql(selected_filters_values)} ORDER BY start_time LIMIT #{limit} OFFSET #{offset}) "\
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
      "#{hide_passed_tests_filter};"

    res
  end

  def test_runs_on_page_sql(selected_filters_values, test_runs_count, columns_count, page_num)
    limit, offset = calc_limit_and_offset(test_runs_count, columns_count, page_num)
    "SELECT * FROM test_run #{filters_to_sql(selected_filters_values)} ORDER BY start_time LIMIT #{limit} OFFSET #{offset}"
  end

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

  def is_i?(str)
    str.to_i.to_s == str
  end
end
