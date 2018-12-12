default['user_name'] = ENV['SUDO_USER']
default['application_name'] = 'maxscale-test-visualizer'
default['repo_path'] = "/home/#{node['user_name']}/#{node['application_name']}"
default['application_path'] = "#{node['repo_path']}/rails-app/"
default['ruby_version'] = '2.5.3'
default['application_repository'] = 'https://github.com/mariadb-corporation/maxscale-test-visualizer'
default['domain_name'] = 'maxscale-test.mariadb.net'
default['users'] = []
# Attributes to install NodeJs on the target machine
default['nodejs']['install_method'] = 'package'
# Theese attributes ar likely to be changed for production
default['db']['username'] = 'test'
default['db']['password'] = 'test'
default['db']['name'] = 'test_results_db'
default['db']['host'] = 'localhost'
default['db']['port'] = '3306'
default['rails_secret'] = 'secret'
default['github']['app_id'] = 'app_id'
default['github']['app_secret'] = 'app_secret'
