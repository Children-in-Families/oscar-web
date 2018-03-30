namespace :client_exit_status do
  desc 'Update status of clients who are already exited NGO and / or exited from programs'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      Client.where(status: 'Referred', state: 'accepted').joins(:client_enrollments).each do |client|
        if client.exit_date.present? && client.exit_note.present?
          client.status = 'Exited'
          client.exit_circumstance = 'Exited Client'

          status_histories = client.versions.where(event: 'update').order(:created_at).select { |v| v.changeset[:status].present? }.map { |a| a.changeset[:status] }.flatten
          if status_histories.include?('Independent - Monitored') || status_histories.include?('Exited Other')
            client.exit_reasons << 'Other'
          elsif status_histories.include?('Exited - Dead') || status_histories.include?('Exited - Deceased') || status_histories.include?('Exited - Deseased')
            client.exit_reasons << 'Client died'
          elsif status_histories.include?('Exited - Age Out')
            client.exit_reasons << 'Client does not meet / no longer meets service criteria'
          elsif status_histories.include?('Exited Independent') || status_histories.include?('Exited Adopted')
            client.exit_reasons << 'Client does not require / no longer requires support'
          end
        else
          client.status = 'Accepted'
        end
        client.save(validate: false)
      end
    end
  end
end
