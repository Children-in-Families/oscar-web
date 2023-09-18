class BillableAcceptedClientsWorker
  include Sidekiq::Worker

  def perform
    Organization.without_shared.where(onboarding_status: 'completed').each do |org|
      begin
        Organization.switch_to org.short_name
        
        PaperTrail::Version.where(accepted_at: Date.current.beginning_of_month..Date.current.end_of_month, billable_at: nil).where.not(billable_report_id: nil).ids.each do |version_id|
          puts "Checking #{org.short_name} version #{version_id}"
          ClientStatusChecker.call(version_id, org.short_name)
        end
      rescue ActiveRecord::StatementInvalid => e
        puts "#{org.short_name} not yet properly setup"
        # continue
      end
    end
  end
end
