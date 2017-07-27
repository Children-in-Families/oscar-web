namespace :clients do
  desc "Set Accepted Date To Client"
  task set_accepted_date: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      paper_trail_clients = PaperTrail::Version.where(item_type: 'Client').where_object_changes(state: 'Accepted')
      paper_trail_clients.each do |paper_trail_client|
        client_id = paper_trail_client.item_id
        client = Client.find_by(id: client_id)
        next if client.nil?
        accepted_date = PaperTrail.serializer.load(paper_trail_client.object_changes)['updated_at'].last
        client.update(accepted_date: accepted_date.to_date)
      end
    end
  end
end
