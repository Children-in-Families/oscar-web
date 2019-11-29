namespace :client_status do
  desc "Update clients status who exited from ngo but status not 'Exited'"
  task correct: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'share'
      Organization.switch_to short_name
      exited_clients = Client.joins(:exit_ngos, :enter_ngos).where("(exit_ngos.exit_date > enter_ngos.accepted_date AND exit_ngos.created_at > enter_ngos.created_at) AND clients.status IN (?)", ['Accepted', 'Active', 'Referred']).order(:id)
      exited_clients.each do |client|
        client.status = 'Exited'
        client.save!(validate: false)
        puts "#{short_name}: client #{client.slug} done!!!"
      end
    end
  end

end
