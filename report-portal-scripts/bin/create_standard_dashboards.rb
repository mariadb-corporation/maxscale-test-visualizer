#!/usr/bin/env ruby
require_relative '../lib/config'
require_relative '../lib/report_portal'

if ARGV.length != 1
  puts <<-EOF
Usage:
  create_standard_dashboards CONFIG_FILE

  CONFIG_FILE: The config file path.
  EOF
  exit 0
end

CONFIG_FILENAME = ARGV.shift

config = Config.new(CONFIG_FILENAME)
PROJECT_NAME = config.project_name
AUTH_TOKEN = config.auth_token
REPORT_PORTAL_URL = config.report_portal_url

report_portal = ReportPortal.new(REPORT_PORTAL_URL, PROJECT_NAME, AUTH_TOKEN)

puts "START\n------\n"
report_portal.all_standard_filters.each do |filter|
  filter_name = filter['name']
  filter_id = filter['id']

  dashboard_id = report_portal.create_dashboard(filter_name, '')
  report_portal.delete_standard_widgets_from_dashboard(dashboard_id)
  widgets = []

  widgets << report_portal.create_widget(
    "Launch statistics line chart #{filter_name} (#{Time.now})",
    'Shows the growth trend in the number of test cases with each selected statuses from run to run',
    'line_chart',
    'old_line_chart',
    filter_id,
    {
      'viewMode' => ['launchMode']
    },
    [
      'statistics$executions$total',
      'statistics$executions$passed',
      'statistics$executions$failed'
    ]
  )

  widgets << report_portal.create_widget(
    "Launch statistics trend chart #{filter_name} (#{Time.now})",
    'Shows the growth trend in the number of test cases with each selected statuses from run to run',
    'trends_chart',
    'statistic_trend',
    filter_id,
    {
      'viewMode' => ['launchMode']
    },
    [
      'statistics$executions$total',
      'statistics$executions$passed',
      'statistics$executions$failed'
    ]
  )

  widgets << report_portal.create_widget(
    "Launch execution and issue statistic #{filter_name} (#{Time.now})",
    'Shows statistics of the last launch',
    'combine_pie_chart',
    'launch_statistics',
    filter_id,
    {  },
    [
      'statistics$executions$total',
      'statistics$executions$passed',
      'statistics$executions$failed'
    ]
  )

  widgets << report_portal.create_widget(
    "Failed cases trend chart #{filter_name} (#{Time.now})",
    'Shows the trend of growth in the number of failed test cases from run to run',
    'bug_trend',
    'bug_trend',
    filter_id,
    { },
    [
      'statistics$executions$total',
      'statistics$executions$passed',
      'statistics$executions$failed'
    ]
  )

  # For some unknown reason it does not work
  #
  # widgets << report_portal.create_widget(
  #   "Passing rate summary #{filter_name} (#{Time.now})",
  #   'Shows the percentage ratio of Passed test cases to Total cases for set of launches',
  #   'bar_chart',
  #   'passing_rate_summary',
  #   filter_id,
  #   {
  #     'viewMode' => ['pieChartMode']
  #   },
  #   [
  #     'statistics$executions$total',
  #     'statistics$executions$passed',
  #     'statistics$executions$failed'
  #   ]
  # )

  widgets.each do |widget_id|
    report_portal.add_widget_to_dashboard(dashboard_id, widget_id)
  end
end

puts "\n------\nFINISH"
