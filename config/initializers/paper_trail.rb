PaperTrail.config.track_associations = true
PaperTrail.config.version_limit = nil

# set whodunnit in rails console
PaperTrail::Rails::Engine.eager_load!

if defined?(::Rails::Console)
  # PaperTrail.whodunnit = "#{`whoami`.strip}: console"
  PaperTrail.whodunnit = "#{`whoami`.strip}@rotati"
elsif defined?(Rake) && Rake.application.name
  # PaperTrail.whodunnit = "#{`whoami`.strip}: #{File.basename($0)} #{ARGV.join ' '}"
  PaperTrail.whodunnit = "#{`whoami`.strip}@rotati"
end

PaperTrail.class_eval do
  def self.without_tracking(&block)
    PaperTrail.enabled = false
    yield
  ensure
    PaperTrail.enabled = true
  end
end
