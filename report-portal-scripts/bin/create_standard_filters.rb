#!/usr/bin/env ruby
require 'mysql2'
require_relative '../lib/config'
require_relative '../lib/report_portal'

if ARGV.length != 1
  puts <<-EOF
Usage:
  create_standard_filters CONFIG_FILE

  CONFIG_FILE: The config file path.
  EOF
  exit 0
end

CONFIG_FILENAME = ARGV.shift

config = Config.new(CONFIG_FILENAME)
USER = config.user
PASSWORD = config.password
PROJECT_NAME = config.project_name
DB_NAME = config.db_name
AUTH_TOKEN = config.auth_token
REPORT_PORTAL_URL = config.report_portal_url

client = Mysql2::Client.new(username: USER, password: PASSWORD,
                            database: DB_NAME)
report_portal = ReportPortal.new(REPORT_PORTAL_URL, PROJECT_NAME, AUTH_TOKEN)
report_portal.create_project

puts "START\n------\n"
report_portal.delete_standard_filters
# Filters by version
client.query('SELECT maxscale_source as source '\
             'FROM test_run '\
             "WHERE maxscale_source <> '' "\
             'GROUP BY maxscale_source').each do |row|
  source = row['source']
  report_portal.add_filter(
    "SOURCE #{source}",
    '',
    [
      {
        'filtering_field' => 'name',
        'condition' => 'cnt',
        'value' => 'TestRun'
      },
      {
        'filtering_field' => 'tags',
        'condition' => 'has',
        'value' => "maxscale:#{source}"
      }
    ]
  )
end

report_portal.add_filter(
  'DAILY TESTS',
  '',
  [
    {
      'filtering_field' => 'name',
      'condition' => 'cnt',
      'value' => 'TestRun'
    },
    {
      'filtering_field' => 'tags',
      'condition' => 'has',
      'value' => 'daily'
    }
  ]
)

puts "\n------\nFINISH"
