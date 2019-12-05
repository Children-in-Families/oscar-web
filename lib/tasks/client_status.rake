namespace :client_status do
  desc "Update clients status who exited from ngo but status not 'Exited'"
  task correct: :environment do
    ngo_client_ids_hash = Hash.new{|hash, key| hash[key] = Array.new }
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'share'
      Organization.switch_to short_name
      exit_ngo_date = "SELECT created_at FROM exit_ngos WHERE exit_ngos.client_id = clients.id ORDER BY created_at DESC LIMIT 1"
      enter_ngo_date = "SELECT created_at FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY created_at DESC LIMIT 1"
      exited_clients = Client.joins(:exit_ngos, :enter_ngos).where("((#{exit_ngo_date}) > (#{enter_ngo_date})) AND clients.status IN (?)", ['Accepted', 'Active', 'Referred']).order(:id).distinct
      # exit_ngo_date = "SELECT exit_date FROM exit_ngos WHERE exit_ngos.client_id = clients.id ORDER BY created_at DESC LIMIT 1"
      # enter_ngo_date = "SELECT accepted_date FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY created_at DESC LIMIT 1"
      # exited_clients = Client.joins(:exit_ngos, :enter_ngos).where("(exit_ngos.exit_date > enter_ngos.accepted_date AND exit_ngos.created_at > enter_ngos.accepted_date) AND clients.status IN (?)", ['Accepted', 'Active', 'Referred']).order(:id)

      exited_clients.each do |client|
        client.status = 'Exited'
        next if client.client_enrollments.present?  && ['meo-254', 'twl-22', 'cen-79', 'ifu-133', 'unm-84', 'kvx-150', 'sol-157', 'mqs-231', 'vto-230', 'eni-232'].include?(client.slug)
        client.save!(validate: false)
        puts "#{short_name}: client #{client.slug} done!!!"
      end

      client_ids = Client.joins(:exit_ngos, :enter_ngos).where("((#{exit_ngo_date}) > (#{enter_ngo_date})) AND clients.status = ?", 'Exited').order(:id).distinct.ids
      Client.joins(:case_worker_clients).where(id: client_ids).group('clients.id').having("COUNT(case_worker_clients) > 0").distinct.each do |client|
        client.case_worker_clients.destroy_all
        puts "#{short_name}: client #{client.slug} done!!!"
      end

      Client.joins(:exit_ngos, :case_worker_clients).where("clients.status = ? AND (SELECT COUNT(case_worker_clients.*) FROM case_worker_clients) > 0", 'Exited').where.not(id: client_ids).order(:id).distinct.each do |client|
        next if client.client_enrollments.present?
        client.case_worker_clients.destroy_all
        puts "#{short_name}: client #{client.slug} done!!!"
      end

      # Client.joins(:client_enrollments).where("clients.status != 'Active' AND (SELECT COUNT(*) FROM client_enrollments WHERE client_enrollments.client_id = clients.id AND status = 'Active' GROUP BY client_enrollments.created_at ORDER BY created_at DESC LIMIT 1) = 1").distinct.each do |client|qg
      # end
    end
    puts ngo_client_ids_hash
  end
end
