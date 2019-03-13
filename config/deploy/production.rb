set :stage, 'production'
set :branch, proc { `git rev-parse --abbrev-ref stable`.chomp }
# TODO: Deploy one after another by commentting out one

# OSCaR
server '52.221.46.112', user: 'deployer', roles: %w{app web db}
