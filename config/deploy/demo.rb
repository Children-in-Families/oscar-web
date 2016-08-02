set :stage, 'demo'
server '172.31.17.167', user: 'deployer', roles: %w{app web db}
