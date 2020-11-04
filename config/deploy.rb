lock '3.9.0'

# set :application, 'children-in-families-web'
set :application, 'oscar-web'
set :repo_url, "git@github.com:DevZep/#{fetch(:application)}.git"

if ENV['CISERVER']
  set :branch, `git rev-parse --abbrev-ref HEAD`.chomp
else
  ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
end

set :deploy_to, "/var/www/#{fetch(:application)}"

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', "public/packs", ".bundle", "node_modules")
set :linked_files, fetch(:linked_files, []).push('.env')

set :pty, false

set :keep_releases, 5

before "deploy:assets:precompile", "deploy:yarn_install"

namespace :deploy do

  task :cleanup_assets do
    on roles :all do
      execute "cd #{release_path}/ && ~/.rvm/bin/rvm default do bundle exec rake assets:clobber RAILS_ENV=#{fetch(:stage)}"
    end
  end

  task :mobile do
    ask :branch, 'master'
    on roles :all do
      mobile_path = '/var/www/cif-mobile/'
      commands = [
        "cd #{mobile_path}",
        "git checkout .",
        "git fetch",
        "git checkout #{fetch(:branch)}",
        "git pull origin #{fetch(:branch)}",
        "npm install",
        "gulp replace --env #{fetch(:stage)}"
      ]
      execute commands.join(" && ")
    end
  end

  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install")
      end
    end
  end

  before :updated, :cleanup_assets
end

set :passenger_restart_with_touch, true

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

require 'appsignal/capistrano'
