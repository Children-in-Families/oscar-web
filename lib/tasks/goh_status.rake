namespace :goh_status do
  desc "Updated exited client status from accepted to exited"
  task correct: :environment do
    Apartment::Tenant.switch 'goh'
    # find all accepted clients who has exited_ngos created_at greater than enter_gnos created_at and change status to exited
    Client.includes(:enter_ngos, :exit_ngos, :client_enrollments).where(status: "Accepted").find_each do |client|
      enter_ngo = client.enter_ngos.last
      exit_ngo = client.exit_ngos.order(:id).last
      client_enrollment = client.client_enrollments.last
      leave_program = client_enrollment&.leave_program
      if enter_ngo.created_at < exit_ngo.created_at && (client.client_enrollments.blank? || (leave_program && leave_program.created_at < exit_ngo.created_at))
        client.update_columns(status: "Exited")
        puts client.slug
      end
    end
  end
end
