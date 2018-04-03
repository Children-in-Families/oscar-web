class StaffMonthlyReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(user_ids, file_name, previous_month, org_short_name, receiver)
    Organization.switch_to org_short_name
    users = User.non_devs.where(id: user_ids)
    StaffMonthlyReportMailer.send_report(users, file_name, previous_month, org_short_name, receiver).deliver_now
  end
end
