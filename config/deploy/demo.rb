set :stage, 'demo'
set :branch, proc { `git rev-parse --abbrev-ref demo`.chomp }
server '3.1.95.54', user: 'deployer', roles: %w{app web db}
