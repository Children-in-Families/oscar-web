set :stage, 'production_api'
set :rails_env, :production_api
set :appsignal_env, :production_api
set :branch, proc { `git rev-parse --abbrev-ref stable`.chomp }
# TODO: Deploy one after another by commentting out one

# OSCaR
server '3.1.204.110', user: 'deployer', roles: %w{app web db}
