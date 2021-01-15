class StaffMonthlyReportMailer < ApplicationMailer
  def send_report(users, file_name, previous_month, org_short_name, receiver)
    @previous_month             = previous_month
    @receiver                   = receiver
    user_emails                 = users.map(&:email)
    dev_email                   = ENV['DEV_EMAIL']
    cc_email                    = [ENV['CIF1_EMAIL'], ENV['CIF2_EMAIL']] if org_short_name == 'cif'
    attachments[file_name.to_s] = File.read(Rails.root.join("tmp/#{file_name}"))
    user_emails.each_slice(50).to_a.each do |emails|
      next if emails.blank?

      mail(to: emails, subject: "Subordinates Performance Report of #{@previous_month}", bcc: dev_email, cc: cc_email)
    end
  end
end
