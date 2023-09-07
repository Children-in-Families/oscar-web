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
      # Accepted day 1, we will have a cron job to check status and set billable_at if the status is still accepted after 7 days
      version.update_columns(
        billable_report_id: report.id,
        billable_status: version.changed_to_status,
        accepted_at: Time.current
      )
    elsif version.changed_to_status_active?
      # Remove accepted item if any
      report.billable_items.where(item_id: version.item_id, item_type: version.item_type, billable_status: 'Accepted').update_all(billable_report_id: nil)
      # Immediately set billable_at for Active status
      version.update_columns(
        billable_report_id: report.id,
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
