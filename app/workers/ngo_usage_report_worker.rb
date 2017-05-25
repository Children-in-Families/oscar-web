class NgoUsageReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(date_time)
    NgoUsageReportMailer.send_report(date_time).deliver_now
  end
end
