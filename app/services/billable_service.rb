class BillableService < ServiceBase
  attr_reader :version, :tenant

  def initialize(version_id, tenant)
    Organization.switch_to(tenant)
    
    @version = PaperTrail::Version.find(version_id)
    @tenant = tenant
  end
  
  def call
    Organization.switch_to(tenant)

    if version.changed_to_status_accepted?
      # Prevent duplicate billable report item in sidekiq concurrency
      return if report.billable_report_items.exists?(billable: version.item)

      # Accepted day 1, we will have a cron job to check status and set billable_at if the status is still accepted after 7 days
      report.billable_report_items.create!(
        version: version,
        billable: version.item,
        billable_status: version.changed_to_status,
        accepted_at: Time.current
      )
    elsif version.changed_to_status_active?
      # Remove accepted item if any
      report.billable_report_items.where(
        version_id: version.id,
        billable_status: 'Accepted'
      ).delete_all

      # Immediately set billable_at for Active status
      report.billable_report_items.create!(
        version: version,
        billable: version.item,
        billable_status: version.changed_to_status,
        billable_at: Time.current
      )
    end
  end
  
  private
  
  def report
    @report ||= BillableReport.find_or_create_by!(
      month: Date.current.month,
      year: Date.current.year,
      organization: Organization.current
    )
  end
end
