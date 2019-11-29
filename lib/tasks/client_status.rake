namespace :client_status do
  desc "TODO"
  task correct: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'share'
      Organization.switch_to short_name
      exited_clients = Client.joins(:exit_ngos, :enter_ngos).where("(exit_ngos.exit_date > enter_ngos.accepted_date AND exit_ngos.created_at > enter_ngos.created_at) AND clients.status IN (?)", ['Accepted', 'Active', 'Referred']).order(:id)
      if exited_clients.present?
        exited_clients.update_all(status: 'Exited')
        puts "#{short_name} done!!!"
      end
    end
  end

end
