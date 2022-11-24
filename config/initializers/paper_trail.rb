PaperTrail.config.track_associations = true
PaperTrail.config.version_limit = nil

# set whodunnit in rails console
PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version < ::ActiveRecord::Base
    belongs_to :user, foreign_key: :whodunnit
  end
end

if defined?(::Rails::Console)
  # PaperTrail.whodunnit = "#{`whoami`.strip}: console"
  PaperTrail.whodunnit = "#{`whoami`.strip}@rotati"
elsif defined?(Rake) && Rake.application.name
  # PaperTrail.whodunnit = "#{`whoami`.strip}: #{File.basename($0)} #{ARGV.join ' '}"
  PaperTrail.whodunnit = "#{`whoami`.strip}@rotati"
end
