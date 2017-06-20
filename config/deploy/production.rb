set :stage, 'production'

server 'oscarhq.com', user: 'deployer', roles: %w{app web db}
