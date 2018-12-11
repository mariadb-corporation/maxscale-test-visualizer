#!/usr/bin/env ruby

# This script is the support script for chef-solo that
# installs the chef on the target computer
# copies all the cookbooks to that computer
# runs the chef-solo to provision the remote server

require 'optparse'
require 'io/console'
require 'net/ssh'
require 'net/scp'
require 'pp'

# Parses the parameters passed to the script. Exits if they are
def parse_parameters
  options = {
    ssh_user: '',
    ssh_server: '',
    chef_config: '',
    chef_version: '14.7.17'
  }

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{__FILE__} -s server.com -u user -j conf/rails-app.json [-v 13.7.16]"

    opts.on('-sSERVER', '--server=SERVER', 'SSH server to connect to, uses the ssh-agent to supply keys.') do |server|
      options[:ssh_server] = server.chomp.strip
    end

    opts.on('-uUSER', '--user=USER', 'Name of the SSH user to use during the connection.') do |user|
      options[:ssh_user] = user.chomp.strip
    end

    opts.on('-jCONFIG', '--json-attributes=CONFIG', 'List of actions to perform on the remote server in JSON format') do |config|
      options[:chef_config] = config.chomp.strip
      unless File.exist?(options[:chef_config])
        puts "You must provide path to the existing configuration file."
        puts "File '#{config}' does not exist!"
        exit 1
      end
    end

    opts.on('-vVERSION', '--version=VERSION', 'Chef version to install on the remote server') do |version|
      options[:chef_version] = version.chomp.strip
    end

    opts.on('-h', '--help', 'Print help and exit') do
      puts opts
      exit 1
    end
  end
  parser.parse(ARGV)

  if options.any? { |_, value| value.empty? }
    puts "You must specify all options to continue."
    puts parser
    exit 1
  end

  options
end

# Read the password that should be used to run sudo
def read_sudo_password
  puts "Please provide sudo password for the remote server."
  print "sudo password: "
  pass = STDIN.noecho(&:gets).chomp.strip
  puts
  if pass.empty?
    puts "You did not specified the password to the remote server."
    exit 1
  end
  pass
end

def vendor_cookbooks
  root = File.absolute_path(File.dirname(__FILE__))
  cookbooks_path = "#{root}/cookbooks"
  Dir.foreach(cookbooks_path) do |cookbook|
    next if cookbook =~ /^\./
    puts "Vendoring '#{cookbook}' cookbook."
    Dir.chdir("#{cookbooks_path}/#{cookbook}")
    puts `berks vendor #{root}/vendor-cookbooks`
  end
  Dir.chdir root
end

def within_ssh_session(server, user, sudo_password)
  options = Net::SSH.configuration_for(server, true)
  Net::SSH.start(server, user, options) do |ssh|
    yield ssh
  end
end

def sudo_exec(connection, sudo_password, command)
  puts "Running 'sudo -S #{command}' on the remote server."
  output = ''
  connection.open_channel do |channel, success|
    channel.on_data do |_, data|
      data.split("\n").reject(&:empty?).each { |line| puts "ssh: #{line}" }
      output += "#{data}\n"
    end
    channel.on_extended_data do |ch, _, data|
      if data =~ /^\[sudo\] password for /
        puts "ssh: providing sudo password"
        ch.send_data "#{sudo_password}\n"
      else
        puts "ssh error: #{data}"
      end
    end
    channel.exec("sudo -S #{command}")
    channel.wait
  end.wait
  output
end

def ssh_exec(connection, command)
  puts "Running '#{command}' on the remote server"
  output = ''
  connection.open_channel do |channel, success|
    channel.on_data do |_, data|
      data.split("\n").reject(&:empty?).each { |line| puts "ssh: #{line}" }
      output += "#{data}\n"
    end
    channel.on_extended_data do |_, _, data|
      puts "ssh error: #{data}"
    end
    channel.exec(command)
    channel.wait
  end.wait
  output
end

def install_chef_on_server(connection, sudo_password, chef_version)
  output = ssh_exec(connection, 'chef-solo --version')
  if output.include?(chef_version)
    puts "Chef #{chef_version} is already installed on the server."
    return
  end
  ssh_exec(connection, 'curl -s -L https://www.chef.io/chef/install.sh --output install.sh')
  sudo_exec(connection, sudo_password, "bash install.sh -v #{chef_version}")
  ssh_exec(connection, 'rm install.sh')
end

def copy_chef_files(connection, remote_dir, sudo_password, chef_config)
  sudo_exec(connection, sudo_password, "rm -rf #{remote_dir}")
  ssh_exec(connection, "mkdir -p #{remote_dir}")
  %w(vendor-cookbooks roles solo.rb).each do |target|
    next unless File.exist?(target)
    puts "Transferring #{target}"
    connection.scp.upload!(target, "#{remote_dir}/#{target}", recursive: true)
  end
  puts "Transferring configuration #{chef_config}"
  connection.scp.upload!(chef_config, "#{remote_dir}/solo.json")
end

def run_chef_solo(connection, remote_dir, sudo_password)
  sudo_exec(connection, sudo_password, "chef-solo -c #{remote_dir}/solo.rb -j #{remote_dir}/solo.json")
end

def main
  parameters = parse_parameters
  sudo_password = read_sudo_password
  vendor_cookbooks
  within_ssh_session(parameters[:ssh_server], parameters[:ssh_user],
                     sudo_password) do |connection|
    install_chef_on_server(connection, sudo_password, parameters[:chef_version])
    remote_dir = '/tmp/provision'
    copy_chef_files(connection, remote_dir, sudo_password, parameters[:chef_config])
    run_chef_solo(connection, remote_dir, sudo_password)
    sudo_exec(connection, sudo_password, "rm -rf #{remote_dir}")
  end
end

main if $0 == __FILE__
