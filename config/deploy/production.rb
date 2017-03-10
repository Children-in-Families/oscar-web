set :stage, 'production'

# 54.169.4.75
server 'cambodianfamilies.com', user: 'deployer', roles: %w{app web db}
