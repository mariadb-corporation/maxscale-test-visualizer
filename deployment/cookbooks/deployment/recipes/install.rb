#
# Cookbook:: deployment
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright:: 2018, MariaDB
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Installing the current version of NodeJs
include_recipe "nodejs"

user_name = node['user_name']
application_name = node['application_name']
repo_path = node['repo_path']
repo_url = node['application_repository']
application_path = node['application_path']
ruby_version = node['ruby_version']
rails_secret = node['rails_secret']

# Update all packages on the target system.
if node['platform_family'] == 'debian'
  apt_update 'update all packages'
end

# Install rbenv and makes it avilable to the selected user. Keeps it up to date.
rbenv_user_install user_name

rbenv_plugin 'ruby-build' do
  git_url 'https://github.com/rbenv/ruby-build.git'
  user user_name
end

rbenv_ruby ruby_version do
  user user_name
end

rbenv_global ruby_version do
  user user_name
end

package 'git'

# Get the latest version of the visualization tool
git repo_path do
  repository repo_url
  revision 'master'
  user user_name
  action :sync
end

# Setup the database
template "#{application_path}/config/database.yml" do
  source 'database.yaml.erb'
  mode '0644'
  owner user_name
end

# Setup application configuration for GitHub authentication
template "#{application_path}/config/application.yml" do
  source 'application.yml.erb'
  mode '0644'
  owner user_name
end

# Setup apache2 to use special port
cookbook_file "#{application_path}/config/settings.yml" do
  action :create_if_missing
  source 'settings.yml'
  mode '0644'
  owner user_name
end

# Install bundler to manage dependencies
rbenv_gem 'bundler' do
  rbenv_version ruby_version
  user user_name
end

# Install all the dependencies for the application
# Install mysql client library to build mysql gem
case node['platform_family']
when 'debian'
  package 'libmysqlclient-dev'
when 'rhel'
  package 'mysql-devel'
end
# Use it to compile JS assets
package 'nodejs' do
  action :upgrade
end

# Install all gems that are required by the application
rbenv_script 'Install required gem files' do
  rbenv_version ruby_version
  user user_name
  cwd application_path
  code 'bundler install'
end

# Rehash all the shims
rbenv_rehash 'Update shims' do
  user user_name
end

# Run asset pipeline for rails
rbenv_script 'Publish all assets' do
  rbenv_version ruby_version
  user user_name
  cwd application_path
  environment({ 'RAILS_ENV' => 'production', 'SECRET_KEY_BASE' => rails_secret})
  code 'rails assets:precompile'
end

# Install SystemD service that will run the application
systemd_unit "#{application_name}.service" do
  content <<~UNIT
    [Unit]
    Decription = MaxScale Test Visualizer
    After = networking.service

    [Service]
    Type = simple
    User = #{user_name}
    WorkingDirectory = #{application_path}
    Environment = "RBENV_VERSION=#{ruby_version}"
    Environment = "SECRET_KEY_BASE=#{rails_secret}"
    ExecStart =  /home/#{user_name}/.rbenv/shims/puma -e production -b tcp://127.0.0.1:9292
    Restart = always

    [Install]
    WantedBy = multi-user.target
  UNIT

  action [:create, :enable, :restart]
end

# Configure apache2 to proxy all calls to the puma or static files
package 'nginx'

template "/etc/nginx/sites-available/#{application_name}" do
  source 'nginx-site.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

# Enable site configuration
link "/etc/nginx/sites-enabled/#{application_name}" do
  to "/etc/nginx/sites-available/#{application_name}"
end

if node['test_env']
  file '/etc/nginx/snippets/ssl-params.conf' do
    action :touch
  end
end

# Check the nginx configuration file
execute 'Check nginx configuration' do
  command 'nginx -t'
end

# Reload apache configuration
service 'nginx' do
  action :restart
end
