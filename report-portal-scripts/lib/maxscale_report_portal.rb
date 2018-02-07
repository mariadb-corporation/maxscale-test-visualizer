# Module for information formatting
module MaxScaleReportPortal

    require 'date'

    config = Config.new(File.expand_path('../config/config.yml', File.dirname(__FILE__)))

    REPOSITORY_URL = config.repository_url
    LOGS_DIR_URL = config.logs_dir_url

    def self.commit_url(commit_id)
        return '#' if commit_id.nil? || commit_id.strip.empty? || commit_id.length != 40
        "#{REPOSITORY_URL}/commit/#{commit_id}"
    end

    def self.logs_url(logs_dir)
        return '#' if logs_dir.nil? || logs_dir.strip.empty?
        "#{LOGS_DIR_URL}/#{logs_dir}"
    end

    def self.launch_name(test_run)
        "TestRun ##{test_run['jenkins_id']}"
    end

    def self.description(test_run)
        "**Target:** #{test_run['target']}\n"\
        "**Box:** #{test_run['box']}\n"\
        "**Product:** #{test_run['product']}\n"\
        "**MariaDB version:** #{test_run['mariadb_version']}\n"\
        "**MaxScale commit:** [#{test_run['maxscale_commit_id']}](#{commit_url(test_run['maxscale_commit_id'])})\n"\
        "**Test code commit:** #{test_run['test_code_commit_id']}\n"\
        "**Job name:** #{test_run['job_name']}\n"\
        "**CMake flags:** #{test_run['cmake_flags']}\n"\
        "**MaxScale source:** #{test_run['maxscale_source']}\n"\
        "**Logs directory:** [#{test_run['logs_dir']}](#{logs_url(test_run['logs_dir'])})"
    end

    def self.start_time(test_run)
        datetime(test_run['start_time'])
    end

    def self.end_time(test_run)
        start_time(test_run)
    end

    def self.launch_tags(test_run)
        [
            test_run['box'],
            test_run['product'],
            "ver:#{test_run['mariadb_version']}",
            "maxscale:#{test_run['maxscale_source']}",
            "target:#{test_run['target']}"
        ] + tags_from_target(test_run['target'])
    end

    def self.tags_from_target(target)
        if !target.nil? && target.include?('daily')
            ['daily']
        else
            []
        end
    end

    def self.test_tags(test_run, test_result)
        launch_tags(test_run)
    end

    def self.datetime(str)
        return DateTime.new(2011, 2, 3.5).strftime('%Y-%m-%dT%H:%M:%SZ') if str.nil?
        begin
            date_res = DateTime.parse(str.to_s).strftime('%Y-%m-%dT%H:%M:%SZ')
        rescue ArgumentError
            return DateTime.new(2001, 2, 3.5).strftime('%Y-%m-%dT%H:%M:%SZ')
        end
        date_res
    end

    def self.test_result_status(test_result)
        if test_result['result'] == 0
            'PASSED'
        else
            'FAILED'
        end
    end
end
