# Class for load configuration from YAML-config file
class Config
    CONFIG_FILE = File.expand_path('../config/config.yml', File.dirname(__FILE__))
    attr_reader :user, :password, :db_name, :project_name, :auth_token, :test_run_count,
                :repository_url, :logs_dir_url, :report_portal_url

    require 'yaml'

    def initialize(config_file_name = nil)
        config_file_name ||= CONFIG_FILE
        check_config_file(config_file_name)

        config = YAML.load(File.read(config_file_name))

        database, rp = check_config_content(config)
        @user = database['user']
        @password = database['password']
        @db_name = database['db_name']
        @test_run_count = database['test_run_count_to_import']
        @project_name = rp['project_name']
        @auth_token = rp['auth_token']
        @repository_url = rp['repository_url']
        @logs_dir_url = rp['logs_dir_url']
        @report_portal_url = rp['url']
    end

    private

    def check_config_file(file_name)
        return if File.file?(CONFIG_FILE)
        
        puts "Error: config.yml file is not exist\n"
        print_config_example
        exit 1
    end

    def check_config_content(config)
        database = config['database']
        rp = config['report_portal']

        if database.nil? || rp.nil? ||
            database['db_name'].nil? || database['user'].nil? || database['password'].nil? ||
            database['test_run_count_to_import'].nil? ||
            rp['project_name'].nil? || rp['auth_token'].nil? ||
            rp['repository_url'].nil? || rp['logs_dir_url'].nil? || rp['url'].nil?
            
            puts "Error: incorrect config.yml file\n"
            print_config_example
            exit 1
        end

        return database, rp
    end

    def print_config_example
        puts <<-EOF
        Please, create config.yml file with the following content:

        ------------
        database:
            db_name: <db_name>
            user: <user_name>
            password: <password>
            test_run_count_to_import: 20
        
        report_portal:
            url: http://localhost:8080
            project_name: <project_name>
            auth_token: "8ee428b5-dcc5-4fba-8e4f-462863dbba15" # Get it from http://localhost:8080/ui/?#user-profile
            repository_url: https://github.com/mariadb-corporation/MaxScale
            logs_dir_url: http://max-tst-01.mariadb.com/LOGS/
        ------------
        EOF
    end
end
