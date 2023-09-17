class ClientStatusChecker < ServiceBase
  attr_reader :version, :tenant

  def initialize(version_id, tenant)
    Organization.switch_to(tenant)
    
    @version = PaperTrail::Version.find(version_id)
    @tenant = tenant
  end

  def call
    Organization.switch_to(tenant)
    # Mark as billable if the status is still accepted after 7 days
    version.update_columns(billable_at: Time.current) if version.item.status == 'Accepted' && version.created_at <= 7.days.ago
  end
end
