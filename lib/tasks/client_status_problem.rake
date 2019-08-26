namespace :client_status_problem do
  desc 'Update client has active program to status active'
  task fix: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Organization.switch_to org.short_name
      Client.joins(:client_enrollments).where(status: 'Accepted').each do |client|
        client.status = 'Active'
        client.save(validate: false)
      end
    end
  end
end
