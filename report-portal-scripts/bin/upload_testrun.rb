#!/usr/bin/env ruby
require 'json'
require_relative '../lib/config'
require_relative '../lib/report_portal'
require_relative '../lib/maxscale_report_portal'

# ReportPortal options
config = Config.new(File.expand_path('../config/config.yml', File.dirname(__FILE__)))

PROJECT_NAME = config.project_name
AUTH_TOKEN = config.auth_token
REPORT_PORTAL_URL = config.report_portal_url

# JSON file keys
ERROR = 'Error'

class BuildResultsUploader

  def initialize
    @report_portal = ReportPortal.new(REPORT_PORTAL_URL, PROJECT_NAME, AUTH_TOKEN)
    @parsed_content = nil
  end

  def upload_results_from_input_file(input_file_path)
    @parsed_content = JSON.parse(File.read(input_file_path))
    @report_portal.create_project
    upload_build_results_to_report_portal(@parsed_content)
  end

  def upload_build_results_to_report_portal(results)
    test_run = test_run_from_results(results)
    launch = @report_portal.start_launch(
        MaxScaleReportPortal.launch_name(test_run),
        'DEFAULT',
        MaxScaleReportPortal.description(test_run),
        MaxScaleReportPortal.start_time(test_run),
        MaxScaleReportPortal.launch_tags(test_run)
    )

    if results.has_key?('tests') && !results.has_key?(ERROR)
        results['tests'].each do |test|
            test_result = test_result_from_test(test)
            @report_portal.add_root_test_item(
                launch,
                test_result['test'],
                MaxScaleReportPortal.description(test_run),
                [],
                MaxScaleReportPortal.start_time(test_run),
                'TEST',
                MaxScaleReportPortal.test_tags(test_run, test_result),
                MaxScaleReportPortal.test_result_status(test_result)
            )
        end
    end

    @report_portal.finish_launch(launch, MaxScaleReportPortal.end_time(test_run), 'PASSED')
  end

  private

  def test_result_from_test(test)
    {
        'test' => test['test_name'],
        'result' => test['test_success'] == 'Failed' ? 1 : 0
    }
  end

  def test_run_from_results(results)
    {
        'jenkins_id' => results['job_build_number'],
        'start_time' => results['timestamp'],
        'target' => results['target'],
        'box' => results['box'],
        'product' => results['product'],
        'mariadb_version' => results['version'],
        'test_code_commit_id' => results['maxscale_system_test_commit'], #? what is that ?
        'maxscale_commit_id' => results['maxscale_commit'],
        'job_name' => results['job_name'],
        'cmake_flags' => results['cmake_flags'],
        'maxscale_source' => results['maxscale_source'],
        'logs_dir' => results['logs_dir']
    }
    end
end


def parse_options
    if ARGV.length != 1
        puts <<-EOF
Usage:
    upload_testrun FILE

    FILE: The parse_ctest_log.rb result json-file path.
    EOF
        exit 0
    end      
    ARGV.shift
end

def main
    input_file_path = parse_options

    puts "START\n------\n"
    uploader = BuildResultsUploader.new
    uploader.upload_results_from_input_file(input_file_path)
    puts "\n------\nFINISH"
end

if File.identical?(__FILE__, $0)    
    main    
end
