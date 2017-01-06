set :stage, 'production'

server '54.169.4.75', user: 'deployer', roles: %w{app web db}
# server '52.77.140.192', user: 'deployer', roles: %w{app web db}
