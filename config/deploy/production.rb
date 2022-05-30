set :stage, 'production'
set :rails_env, :production
set :appsignal_env, :production
set :branch, proc { `git rev-parse --abbrev-ref demo-production`.chomp }
# TODO: Deploy one after another by commentting out one

# OSCaR
server '13.215.194.167', user: 'deployer', roles: %w{app web db}
