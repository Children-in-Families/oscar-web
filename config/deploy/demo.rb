set :stage, 'demo'
server '3.1.95.54', user: 'deployer', roles: %w{app web db}
