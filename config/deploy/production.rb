set :stage, 'production'

server 'cambodianfamilies.com', user: 'deployer', roles: %w{app web db}
