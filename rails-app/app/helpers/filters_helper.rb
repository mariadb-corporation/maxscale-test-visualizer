module FiltersHelper
  def format_test_result(test_result)
    return '' if test_result.nil?

    if test_result.result == 1
      'close'
    else
      'checkmark'
    end
  end

  def icon_color(value)
    return '' if value.nil?
    if value.result == 0
      'text-success'
    else
      'text-danger'
    end
  end

  def option_selected?(option, filter_selects)
    !filter_selects.nil? && filter_selects.include?(option)
  end

  def test_run_info(test_run)
    "<b>id:</b> #{test_run.id} <br>"\
    "<b>Start time:</b> #{test_run.start_time} <br>"\
    "<b>Target:</b> #{test_run.target} <br>"\
    "<b>Box:</b> #{test_run.box} <br>"\
    "<b>Product:</b> #{test_run.product} <br>"\
    "<b>MariaDB version:</b> #{test_run.mariadb_version} <br>"\
    "<b>Maxscale source:</b> #{test_run.maxscale_source} <br>"\
    "<b>Job name:</b> #{test_run.job_name} <br>"\
    "<b>CMake flags:</b> #{test_run.cmake_flags} <br>"\
    "<b>Maxscale commit:</b> #{test_run.maxscale_commit_id} <br>"\
  end

  def logs_url(jenkins_id)
    main_url = 'http://max-tst-01.mariadb.com/LOGS/'
    main_url + 'run_test-' + jenkins_id.to_s
  end
end
