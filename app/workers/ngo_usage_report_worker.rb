class NgoUsageReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform
    NgoUsageReportMailer.send_report.deliver_now
  end
end
