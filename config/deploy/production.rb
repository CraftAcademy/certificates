# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

server ENV['PROD_SERVER'], user: ENV['SSH_USER'], roles: %w(app web)
set :branch, 'master'
set :deploy_to, ENV['PROD_PATH']
set :rvm_ruby_version, '2.3.4'
