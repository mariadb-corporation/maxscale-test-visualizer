module FiltersHelper

  REPOSITORY_URL = 'https://github.com/mariadb-corporation/MaxScale'.freeze
  LOGS_DIR_URL = 'http://max-tst-01.mariadb.com/LOGS'.freeze

  def commit_url(commit_id)
    if commit_id.nil? || commit_id.strip.empty? || commit_id.length != 40
      return '#'
    end
    "#{REPOSITORY_URL}/commit/#{commit_id}"
  end

  def logs_url(logs_dir)
    return '#' if logs_dir.nil? || logs_dir.strip.empty?
    "#{LOGS_DIR_URL}/#{logs_dir}"
  end

  def test_logs_url(logs_dir, test_name)
    return '#' if logs_dir.nil? || logs_dir.strip.empty?
    "#{LOGS_DIR_URL}/#{logs_dir}/LOGS/#{test_name}"
  end

  def format_test_result(test_result)
    return '' if test_result.nil?

    if test_result['result'] == 1
      'close'
    else
      'checkmark'
    end
  end

  def icon_color(value)
    return '' if value.nil?
    if value['result'] == 0
      'text-success'
    else
      'text-danger'
    end
  end

  def option_selected?(option, filter_selects)
    !filter_selects.nil? && filter_selects.include?(option)
  end

  def test_run_info(test_run)
    "<b>id:</b> #{test_run['id']} <br>"\
    "<b>Start time:</b> #{test_run['start_time']} <br>"\
    "<b>Target:</b> #{test_run['target']} <br>"\
    "<b>Box:</b> #{test_run['box']} <br>"\
    "<b>Product:</b> #{test_run['product']} <br>"\
    "<b>MariaDB version:</b> #{test_run['mariadb_version']} <br>"\
    "<b>Maxscale source:</b> #{test_run['maxscale_source']} <br>"\
    "<b>Job name:</b> #{test_run['job_name']} <br>"\
    "<b>CMake flags:</b> #{test_run['cmake_flags']} <br>"\
    "<b>Maxscale commit:</b> <a href='#{commit_url(test_run['maxscale_commit_id'])}'>#{test_run['maxscale_commit_id']}</a> <br>"\
    "<b>Logs:</b> <a href='#{logs_url(test_run['logs_dir'])}'>#{test_run['logs_dir']}</a> <br>"\
  end

  def test_result(final_result, test_run, test_name)
    res = final_result.find{ |res| res['id'] == test_run['id'] && res['test'] == test_name}
  end
end
