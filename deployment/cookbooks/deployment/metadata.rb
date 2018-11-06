name 'deployment'
maintainer 'MariaDB'
maintainer_email 'andrey.vasilyev@fruct.org'
license 'MIT'
description 'Installs/Configures MaxScale Test Visualizer'
long_description 'Installs/Configures the Rails MaxScale Test Visualizer'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The ubuntu is the only system that is currently supported.
supports 'ubuntu'

# List of dependencies for the current cookbook

depends 'ruby_rbenv'
depends 'nodejs'
