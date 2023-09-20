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

PaperTrail::Version.class_eval do
  after_commit :assign_billable_report, on: :create

  def client?
    item_type == 'Client'
  end

  def family?
    item_type == 'Family'
  end

  def client_or_family?
    client? || family?
  end

  def billable?
    object_changes && object_changes['status'] && changed_to_status.in?(%w[Active Accepted])
  end

  def changed_to_status_active?
    changed_to_status == 'Active'
  end

  def changed_to_status_accepted?
    changed_to_status == 'Accepted'
  end

  def changed_to_status
    object_changes &&
    object_changes['status'] &&
    object_changes['status'].last
  end
  
  def assign_billable_report
    return if Rails.env.test?
    return unless client_or_family?
    return unless billable?
 
    puts "====================== Assigning billable report for #{item_type} #{item_id} with status #{changed_to_status} on schema #{Apartment::Tenant.current} ======================"

    if Rails.env.development?
      BillableService.call(self.id, Apartment::Tenant.current)
    else
      BillableService.delay.call(self.id, Apartment::Tenant.current)
    end
  end
end
