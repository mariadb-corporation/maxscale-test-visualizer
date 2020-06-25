module FiltersHelper
  REPOSITORY_URL = 'https://github.com/mariadb-corporation/MaxScale'.freeze
  LOGS_DIR_URL = 'https://mdbe-ci-repo.mariadb.net/bb-logs/Maxscale'.freeze

  def commit_url(commit_id)
    if commit_id.nil? || commit_id.strip.empty? || commit_id.length != 40
      return '#'
    end
    "#{REPOSITORY_URL}/commit/#{commit_id}"
  end

  def logs_url(job_name, jenkins_id)
    return '#' if [job_name, jenkins_id].include?(nil)
    "#{LOGS_DIR_URL}/#{job_name}-#{jenkins_id}/"
  end

  def test_logs_url(job_name, jenkins_id, test_name)
    return '#' if [job_name, jenkins_id].include?(nil)
    "#{logs_url(job_name, jenkins_id)}LOGS/#{test_name}/"
  end

  def logs_url_for_performance_test_run(jenkins_id)
    "#{LOGS_DIR_URL}/performance_test-#{jenkins_id}/"
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

  def performance_test_run_info(test_run)
    "<b>id:</b> #{test_run['id']} <br>"\
    "<b>Jenkins id:</b> #{test_run['jenkins_id']} <br>"\
    "<b>Start time:</b> #{test_run['start_time']} <br>"\
    "<b>Target:</b> #{test_run['target']} <br>"\
    "<b>Box:</b> #{test_run['box']} <br>"\
    "<b>Product:</b> #{test_run['product']} <br>"\
    "<b>MariaDB version:</b> #{test_run['mariadb_version']} <br>"\
    "<b>Test code commit id:</b> #{test_run['test_code_commit_id']} <br>"\
    "<b>Job name:</b> #{test_run['job_name']} <br>"\
    "<b>Machine count:</b> #{test_run['machine_count']} <br>"\
    "<b>Sysbench params:</b> #{test_run['sysbench_params']} <br>"\
    "<b>Test tool:</b> #{test_run['test_tool']} <br>"\
    "<b>Test tool version:</b> #{test_run['test_tool_version']} <br>"\
    "<b>Product under test:</b> #{test_run['product_under_test']} <br>"\
    "<b>Maxscale source:</b> #{test_run['maxscale_source']} <br>"\
    "<b>Maxscale threads:</b> #{test_run['maxscale_threads']} <br>"\
    "<b>Sysbench threads:</b> #{test_run['sysbench_threads']} <br>"\
    "<b>Maxscale commit:</b> <a href='#{commit_url(test_run['maxscale_commit_id'])}'>#{test_run['maxscale_commit_id']}</a> <br>"\
    "<b>Logs:</b> <a href='#{logs_url_for_performance_test_run(test_run['jenkins_id'])}'>#{test_run['jenkins_id']}</a> <br>"\
    "<b>MBCI template:</b> <a href=#{mdbci_template_path(id: test_run['id'])}>Template</a> <br>"\
    "<b>Maxscale config:</b> <a href=#{maxscale_cnf_path(id: test_run['id'])}>Config</a> <br>"
  end

  def leak_summary_info(leak_summary)
    leak_summary.gsub("\n", '<br>')
  end

  def test_result(final_result, target_build, test_name)
    final_result.select { |res| res['target_build_id'] == target_build['id'] && res['test'] == test_name}
  end

  def test_runs_by_target_build(target_build_id)
    @test_runs.select { |test_run| test_run[:target_build_id] == target_build_id }
  end

  def test_run_by_id(id)
    @test_runs.find { |test_run| test_run[:id] == id }
  end
end
