set :stage, 'production'
set :rails_env, :production
set :appsignal_env, :production
set :branch, proc { `git rev-parse --abbrev-ref stable`.chomp }
# TODO: Deploy one after another by commentting out one

# OSCaR genderal
server '52.221.46.112', user: 'deployer', roles: %w{app web db worker cron}, ssh_options: {
  :keepalive => true,
  :keepalive_interval => 60 #seconds
}
