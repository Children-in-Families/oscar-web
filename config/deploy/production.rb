set :stage, 'production'
set :rails_env, :production
set :appsignal_env, :production
set :branch, proc { `git rev-parse --abbrev-ref stable`.chomp }
# TODO: Deploy one after another by commentting out one

# OSCaR
server '18.136.184.226', user: 'deployer', roles: %w{app web db}
