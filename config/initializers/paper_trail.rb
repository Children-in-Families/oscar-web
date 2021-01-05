require 'rake'
PaperTrail.config.version_limit = nil
PaperTrail.config.track_associations = true

# set whodunnit in rails console
PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version < ::ActiveRecord::Base
    include PaperTrail::VersionConcern
    # belongs_to :user, foreign_key: :whodunnit
  end
end

if defined?(::Rails::Console)
  # PaperTrail.whodunnit = "#{`whoami`.strip}: console"
  PaperTrail.request.whodunnit = "#{`whoami`.strip}@rotati"
elsif defined?(Rake) && Rake.application.name
  # PaperTrail.whodunnit = "#{`whoami`.strip}: #{File.basename($0)} #{ARGV.join ' '}"
  PaperTrail.request.whodunnit = "#{`whoami`.strip}@rotati"
end
