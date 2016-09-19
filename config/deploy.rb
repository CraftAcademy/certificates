# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'ca_certificates'
set :repo_url, 'git@github.com:CraftAcademy/certificates.git'
set :passenger_restart_with_touch, true

# Default value for :linked_files is []
append :linked_files, '.env'

# Default value for linked_dirs is []
# append :linked_dirs, 'pdf'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# SSH Options
set :ssh_options, forward_agent: true
