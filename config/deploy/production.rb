set :stage, 'production'

server 'http://cambodianfamilies.com/', user: 'deployer', roles: %w{app web db}
