class ClientStatusChecker < ServiceBase
  attr_reader :tenant, :billable_report_item

  def initialize(billable_item, tenant)
    @billable_report_item = BillableReportItem.find(billable_item)
    @tenant = tenant
  end

  def call
    Organization.switch_to(tenant)

    version = billable_report_item.version
    # Data bug
    return unless version.client_or_family?

    # Mark as billable if the status is still accepted after 7 days
    billable_report_item.update_columns(billable_at: Time.current) if version.item.try(:status) == 'Accepted' && version.created_at.to_date <= 7.days.ago.to_date
  end
end
