set :stage, 'production_api'
set :rails_env, :production_api
set :appsignal_env, :production_api
set :branch, proc { `git rev-parse --abbrev-ref 2023060603-create-instant-for-primero-api`.chomp }
# TODO: Deploy one after another by commentting out one

# OSCaR
server '3.0.81.117', user: 'deployer', roles: %w{app}
