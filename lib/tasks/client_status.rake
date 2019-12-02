namespace :client_status do
  desc "Update clients status who exited from ngo but status not 'Exited'"
  task correct: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'share'
      Organization.switch_to short_name
      exit_ngo_date = "SELECT created_at FROM exit_ngos WHERE exit_ngos.client_id = clients.id ORDER BY created_at DESC LIMIT 1"
      enter_ngo_date = "SELECT created_at FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY created_at DESC LIMIT 1"
      exited_clients = Client.joins(:exit_ngos, :enter_ngos).where("((#{exit_ngo_date}) > (#{enter_ngo_date})) AND clients.status IN (?)", ['Accepted', 'Active', 'Referred']).order(:id)
      # exited_clients.each do |client|
      #   binding.pry if short_name != 'demo'
      #   client.status = 'Exited'
      #   client.save!(validate: false)
      #   puts "#{short_name}: client #{client.slug} done!!!"
      # end

      # Client.joins(:case_worker_clients).where(status: 'Exited').group('clients.id').having("COUNT(case_worker_clients) > 0").distinct.each do |client|
      #   client.case_worker_clients.destroy_all
      #   puts "#{short_name}: client #{client.slug} done!!!"
      # end

      Client.joins(:client_enrollments).where("clients.status != 'Active' AND (SELECT COUNT(*) FROM client_enrollments WHERE client_enrollments.client_id = clients.id AND status = 'Active' GROUP BY client_enrollments.created_at ORDER BY created_at DESC LIMIT 1) = 1").each do |client|
        next if short_name == 'demo'
      end
    end
  end
end
