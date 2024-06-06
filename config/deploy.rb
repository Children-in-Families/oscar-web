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

set :sidekiq_roles, :worker
set :assets_roles, [:web]
set :whenever_roles, [:cron]

set :deploy_to, "/var/www/#{fetch(:application)}"

set :linked_dirs, fetch(:linked_dirs, []).push('vendor/data', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/packs', '.bundle')
set :linked_files, fetch(:linked_files, []).push('.env')

set :pty, false

set :keep_releases, 5

namespace :deploy do
  task :mobile do
    ask :branch, 'master'
    on roles :all do
      mobile_path = '/var/www/cif-mobile/'
      commands = [
        "cd #{mobile_path}",
        'git checkout .',
        'git fetch',
        "git checkout #{fetch(:branch)}",
        "git pull origin #{fetch(:branch)}",
        'npm install',
        "gulp replace --env #{fetch(:stage)}"
      ]
      execute commands.join(' && ')
    end
  end

  task :link_sidekiq_assets do
    bundle_path = capture "cd #{release_path}; bundle show sidekiq"
    bundle_path = "#{bundle_path.strip}/web/assets"
    run "ln -nfs #{bundle_path} #{release_path}/public/sidekiq"
  end
end

set :passenger_restart_with_touch, true

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
