class NgoUsageReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email', retry: false

  def perform(date_time, previous_month)
    NgoUsageReportMailer.send_report(date_time, previous_month).deliver_now
  end
end
