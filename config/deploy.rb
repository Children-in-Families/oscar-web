lock '3.9.0'

# set :application, 'children-in-families-web'
set :application, 'oscar-web'
set :repo_url, "git@github.com:Children-in-Families/#{fetch(:application)}.git"

if ENV['CISERVER']
  set :branch, `git rev-parse --abbrev-ref HEAD`.chomp
else
  ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
end

set :appsignal_revision, `git log --pretty=format:'%h' -n 1 #{fetch(:branch)}`

set :deploy_to, "/var/www/#{fetch(:application)}"

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', "public/packs", ".bundle", "node_modules")
set :linked_files, fetch(:linked_files, []).push('.env')

set :pty, false

set :keep_releases, 5

if ENV['SKIP_ASSETS']
  Rake::Task['deploy:assets:precompile'].clear_actions
  Rake::Task['deploy:assets:backup_manifest'].clear_actions
else
  before "deploy:assets:precompile", "deploy:yarn_install"
end

namespace :deploy do

  task :cleanup_assets do
    on roles :all do
      execute "cd #{release_path}/ && ~/.rvm/bin/rvm default do bundle exec rake assets:clobber RAILS_ENV=#{fetch(:stage)}" unless ENV['SKIP_ASSETS']
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

# after :deploy, 'cache:clear'

namespace :cache do
  task :clear do
    on roles(:app) do |host|
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, "rake cache:clear"
        end
      end
    end
  end
end


set :passenger_restart_with_touch, true

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
