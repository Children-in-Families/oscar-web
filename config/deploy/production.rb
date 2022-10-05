set :stage, 'production'
set :rails_env, :production
set :appsignal_env, :production
set :branch, proc { `git rev-parse --abbrev-ref demo-production`.chomp }
# TODO: Deploy one after another by commentting out one

# OSCaR
server '54.255.207.134', user: 'deployer', roles: %w{app web db}
