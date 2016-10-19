set :stage, 'production'

server '52.74.183.48', user: 'deployer', roles: %w{app web db}
# server '52.77.140.192', user: 'deployer', roles: %w{app web db}
