default['user_name'] = ENV['SUDO_USER']
default['application_name'] = 'maxscale-test-visualizer'
default['repo_path'] = "/home/#{node['user_name']}/#{node['application_name']}"
default['application_path'] = "#{node['repo_path']}/rails-app/"
default['ruby_version'] = '2.5.0'
default['application_repository'] = 'https://github.com/mariadb-corporation/maxscale-test-visualizer'
# Theese attributes ar likely to be changed for production
default['db']['username'] = 'test'
default['db']['password'] = 'test'
default['rails_secret'] = 'secret'
