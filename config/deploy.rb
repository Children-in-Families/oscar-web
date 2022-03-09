lock '3.9.0'

# set :application, 'children-in-families-web'
set :application, 'oscar-web'
set :repo_url, "git@github.com:Children-in-Families/#{fetch(:application)}.git"

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

namespace :appsignal do
  # Description is required for it to show up in the tasks list.
  desc 'Notify AppSignal of this deploy!'
  task :deploy do
    # 1. Needs to be run inside an `on` block
    # 2. `appsignal_roles` setting set and supplied with default
    on roles(fetch(:appsignal_roles, :app)) do
      env = fetch(:rails_env, 'production')
      user = ENV['USER'] || ENV['USERNAME']

      appsignal_config = Appsignal::Config.new(
        ENV['PWD'],
        env,
        fetch(:appsignal_config, {}),
        self
      )

      if appsignal_config && appsignal_config.active?
        # `current_revision` method has been removed.
        # When run from `deploy` the `current_revision` setting should be
        # set (see:
        # https://github.com/capistrano/capistrano/blob/3d641ea994627a22edd01529440b12a9e565001d/lib/capistrano/tasks/git.rake#L52
        # https://github.com/capistrano/capistrano/blob/5986983915163e6681f2546bf6fad599d58cd024/lib/capistrano/dsl.rb#L32
        # ), otherwise (when run with `cap appsignal:deploy`) check again with
        # `fetch_revision`.
        marker_data = {
          revision: fetch(:current_revision) || fetch_revision,
          repository: fetch(:repo_url),
          user: user
        }

        marker = Appsignal::Marker.new(marker_data, appsignal_config, self)
        # Dry run conditional removed, now Capistrano does this on a higher level.
        marker.transmit
      end
    end
  end
end

after 'deploy', 'appsignal:deploy'

set :passenger_restart_with_touch, true

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :appsignal_revision, `git log --pretty=format:'%h' -n 1 #{fetch(:branch)}`
set :appsignal_user, "deployer"
