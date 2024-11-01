set :stage, 'staging'
set :rails_env, :staging
set :appsignal_env, :staging
set :branch, proc { `git rev-parse --abbrev-ref staging`.chomp }

server '3.0.131.11', user: 'deployer', roles: %w{app web db worker cron}
