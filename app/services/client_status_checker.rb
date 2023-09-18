class ClientStatusChecker < ServiceBase
  attr_reader :tenant, :billable_report_item

  def initialize(billable_item, tenant)
    @billable_report_item = BillableReportItem.find(billable_item)
    @tenant = tenant
  end
  
  def call
    Organization.switch_to(tenant)

    version = billable_report_item.version
    # Mark as billable if the status is still accepted after 7 days
    billable_report_item.update_columns(billable_at: Time.current) if version.item.status == 'Accepted' && version.created_at <= 7.days.ago
  end
end
