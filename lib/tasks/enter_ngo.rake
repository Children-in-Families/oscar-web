namespace :enter_ngo do
  desc "check every client if status active but has no accepted date"
  task check_and_create: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
      Client.joins(:assessments).includes(:enter_ngos).where(status: 'Active').where("(SELECT COUNT(*) FROM enter_ngos WHERE clients.id = enter_ngos.client_id) = 0").references(:enter_ngos).each do |client|
        client_changeset = client.versions.where(event: 'update').where("versions.object_changes ILIKE '%status%'").first&.changeset
        if client_changeset
          EnterNgo.skip_callback(:create, :after, :update_client_status)
          the_date = client_changeset['updated_at'].last
          client.enter_ngos.create(accepted_date: the_date, client_id: 719, created_at: the_date, updated_at: the_date) if client_changeset['status'].last == 'Accepted'
          puts "#{short_name} client: #{client.slug}"
        end
      end
    end
  end

end
