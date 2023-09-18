class BillableAcceptedClientsWorker
  include Sidekiq::Worker

  def perform
    Organization.without_shared.where(onboarding_status: 'completed').each do |org|
      Organization.switch_to org.short_name

      PaperTrail::Version.where(accepted_at: Date.current.beginning_of_month..Date.current.end_of_month, billable_at: nil).where.not(billable_report_id: nil).ids do |version_id|
        ClientStatusChecker.delay.call(version_id, org.short_name)
      end
    end
  end
end
