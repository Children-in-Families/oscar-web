set :stage, 'production'

# TODO: Deploy one after another by commentting out one

# OSCaR
server 'oscarhq.com', user: 'deployer', roles: %w{app web db}

# Mother's Heart
# server '13.228.241.79', user: 'deployer', roles: %w{app web db}