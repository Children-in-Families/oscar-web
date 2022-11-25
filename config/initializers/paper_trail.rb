PaperTrail.config.track_associations = true
PaperTrail.config.version_limit = nil

# set whodunnit in rails console
# the following line is required for PaperTrail >= 4.0.0 and < 12.0.0 with Rails
# PaperTrail::Rails::Engine.eager_load!

# Defer evaluation in case we're using spring loader (otherwise it would be something like "spring app    | app | started 13 secs ago | development")
PaperTrail.request.whodunnit = ->() {
  if Rails.const_defined?('Console') || File.basename($PROGRAM_NAME) == 'rake'
    # "#{`whoami`.strip}: console"
    "#{`whoami`.strip}@rotati"
  elsif defined?(Rake) && Rake.application.name
    "#{`whoami`.strip}@rotati"
  else
    "#{`whoami`.strip}: #{File.basename($PROGRAM_NAME)} #{ARGV.join ' '}"
  end
}
