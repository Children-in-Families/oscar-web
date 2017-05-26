class NgoUsageReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(date_time, previous_month)
    NgoUsageReportMailer.send_report(date_time, previous_month).deliver_now
  end
end
