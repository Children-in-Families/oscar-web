set :stage, 'production'

server '52.74.183.48', user: 'deployer', roles: %w{app web db}
