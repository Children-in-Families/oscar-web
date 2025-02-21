set :stage, 'staging'
set :rails_env, :staging
set :appsignal_env, :staging
set :branch, proc { `git rev-parse --abbrev-ref staging`.chomp }

server '193.203.160.204', user: 'deployer', roles: %w{app web db worker cron}
