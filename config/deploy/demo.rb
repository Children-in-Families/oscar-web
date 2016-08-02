set :stage, 'demo'
server '52.74.170.207', user: 'deployer', roles: %w{app web db}
