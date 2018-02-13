# Class for load configuration from YAML-config file
class Config
  attr_reader :user, :password, :db_name, :project_name, :auth_token,
              :report_portal_url

  require 'yaml'

  def initialize(config_file_name)
    check_config_file(config_file_name)

    config = YAML.safe_load(File.read(config_file_name))

    database_root, report_portal_root = check_config_content(config)
    init_fields(database_root, report_portal_root)
  end

  private

  def init_fields(database_root, report_portal_root)
    @user = database_root['user']
    @password = database_root['password']
    @db_name = database_root['db_name']
    @project_name = report_portal_root['project_name']
    @auth_token = report_portal_root['auth_token']
    @report_portal_url = report_portal_root['url']
  end

  def check_config_file(file_name)
    return if file_name.nil? || File.file?(file_name)

    puts "Error: config.yml file is not exist\n"
    print_config_example
    exit 1
  end

  def check_config_content(config)
    database = config['database']
    rp = config['report_portal']

    if database.nil? || rp.nil? ||
       database['db_name'].nil? || database['user'].nil? ||
       database['password'].nil? ||
       rp['project_name'].nil? || rp['auth_token'].nil? ||
       rp['url'].nil?

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

report_portal:
    url: http://localhost:8080
    project_name: <project_name>
    auth_token: "8ee428b5-dcc5-4fba-8e4f-462863dbba15" # Get it from http://localhost:8080/ui/?#user-profile
------------
    EOF
  end
end
