namespace :goh_status do
  desc "Updated exited client status from accepted to exited"
  task correct: :environment do
    Apartment::Tenant.switch 'goh'
    # find all accepted clients who has exited_ngos created_at greater than enter_gnos created_at and change status to exited
    Client.joins(:enter_ngos, :exit_ngos).where(status: "Accepted").each do |client|
      if client.enter_ngos.last.created_at < client.exit_ngos.last.created_at && client.client_enrollments.blank?
        client.update_columns(status: "exited")
        puts client.slug
      end
    end
  end
end
