namespace :client_status do
  desc "Update clients status who exited from ngo but status not 'Exited'"
  task :correct, [:short_name] => :environment do |task, args|
    ngo_client_ids_hash = Hash.new{|hash, key| hash[key] = Array.new }
    short_name = args.short_name
    Organization.switch_to short_name
    exit_ngo_date = "SELECT created_at FROM exit_ngos WHERE exit_ngos.client_id = clients.id AND exit_ngos.deleted_at IS NULL ORDER BY created_at DESC LIMIT 1"
    enter_ngo_date = "SELECT created_at FROM enter_ngos WHERE enter_ngos.client_id = clients.id AND enter_ngos.deleted_at IS NULL ORDER BY created_at DESC LIMIT 1"
    exited_clients = Client.joins(:exit_ngos, :enter_ngos).where("((#{exit_ngo_date}) > (#{enter_ngo_date})) AND clients.status IN (?)", ['Accepted', 'Active', 'Referred']).order(:id).distinct
    exit_ngo_date = "SELECT exit_date FROM exit_ngos WHERE exit_ngos.client_id = clients.id ORDER BY created_at DESC LIMIT 1"
    enter_ngo_date = "SELECT accepted_date FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY created_at DESC LIMIT 1"
    exited_clients = Client.joins(:exit_ngos, :enter_ngos).where("(exit_ngos.exit_date > enter_ngos.accepted_date AND exit_ngos.created_at > enter_ngos.accepted_date) AND clients.status IN (?)", ['Accepted', 'Active', 'Referred']).order(:id)

    client_ids = Client.includes(:exit_ngos, :enter_ngos).references(:exit_ngos).where("((#{exit_ngo_date}) > (#{enter_ngo_date})) AND clients.status = ?", 'Exited').order(:id).distinct.ids
    Client.joins(:case_worker_clients).where(id: client_ids).group('clients.id').having("COUNT(case_worker_clients) > 0").distinct.each do |client|
      client.case_worker_clients.destroy_all
      puts "#{short_name}: removed caseworker from client #{client.slug} done!!!"
    end

    Client.joins(:exit_ngos, :case_worker_clients).where("clients.status = ? AND (SELECT COUNT(case_worker_clients.*) FROM case_worker_clients) > 0", 'Exited').where.not(id: client_ids).order(:id).distinct.each do |client|
      next if client.client_enrollments.present?
      client.case_worker_clients.destroy_all
      puts "#{short_name}: removed caseworker from client client #{client.slug} done!!!"
    end

    Client.includes(client_enrollments: :leave_program).references(:client_enrollments).distinct.where("clients.status = ? AND (SELECT COUNT(*) FROM client_enrollments WHERE client_enrollments.status = ? AND client_enrollments.client_id = clients.id) = 0", 'Active', 'Active').distinct.each do |client|
      cps_enrollment = client.client_enrollments.last
      cps_leave_program = LeaveProgram.joins(:client_enrollment).where("client_enrollments.client_id = ?", client.id).last
      if (cps_enrollment && cps_leave_program)
        if cps_leave_program.created_at > cps_enrollment.created_at && client.exit_ngos.blank?
          client.status = 'Accepted'
          client.save!(validate: false)

          puts "#{short_name}: changed status client #{client.slug} done!!!"
        end
      end
    end

    Client.includes(:enter_ngos, :client_enrollments).references(:client_enrollments).where("(SELECT COUNT(*) FROM enter_ngos WHERE (enter_ngos.client_id = clients.id AND enter_ngos.deleted_at IS NULL) AND clients.status != 'Active') = 2").distinct.each do |client|
      cps_leave_program = LeaveProgram.joins(:client_enrollment).where("client_enrollments.client_id = ?", client.id).last
      if cps_leave_program.present?
        if client.enter_ngos.count > client.exit_ngos.count
          next if client.status == 'Accepted'
          client.enter_ngos.first.destroy
          puts "#{short_name}: destroyed first accept NGO of client #{client.slug} done!!!"
        end
      else
        client.enter_ngos.last.destroy
        client.status = 'Active'
        client.save!(validate: false)
        puts "#{short_name}: destroyed last accept NGO and changed status client #{client.slug} to Active done!!!"
      end
    end

    Client.joins(:enter_ngos, :client_enrollments).where("(SELECT COUNT(*) FROM enter_ngos WHERE enter_ngos.client_id = clients.id AND enter_ngos.deleted_at IS NULL) = 2").distinct.each do |client|
      if client.enter_ngos.count > client.exit_ngos.count
        next if client.exit_ngos.present? && (client.enter_ngos.last.created_at > client.exit_ngos.last.created_at)
        client.enter_ngos.first.destroy
        puts "#{short_name}: destroyed first accept NGO of client #{client.slug} done!!!"
      end
    end

    Client.joins(:enter_ngos, :client_enrollments).where("(SELECT COUNT(*) FROM enter_ngos WHERE enter_ngos.client_id = clients.id AND enter_ngos.deleted_at IS NULL) >= 1 AND clients.status = 'Accepted'").distinct.each do |client|
      if client.enter_ngos.count > client.exit_ngos.count && client.exit_ngos.count.zero? && (client.client_enrollments.present? && client.client_enrollments.where(status: 'Exited').count.zero?)
        client.status = 'Active'
        client.save!(validate: false)
        puts "#{short_name}: Update client accept NGO status to 'Active' of client #{client.slug} done!!!"
      end
      next if client.exit_ngos.last.nil? || client.client_enrollments.last.status == 'Exited'
      if client.client_enrollments.last.created_at > client.enter_ngos.last.created_at && client.enter_ngos.last.created_at > client.exit_ngos.last.created_at
        client.status = 'Active'
        client.save!(validate: false)
        puts "#{short_name}: Update client accept NGO status to 'Active' of client #{client.slug} done!!!"
      end
    end

    Client.includes(:exit_ngos, :program_streams).references(:exit_ngos).group("clients.id, exit_ngos.id, program_streams.id").having("COUNT(exit_ngos.*) = 1").where("clients.status = 'Active' AND exit_ngos.created_at > client_enrollments.created_at").each do |client|
      if client.exit_ngos.last.created_at > client.client_enrollments.last.created_at
        client.status = 'Exited'
        client.save!(validate: false)
        puts "#{short_name}: Update client status to 'Exited' of client #{client.slug} done!!!"
      end
    end

    sql = "SELECT clients.id FROM clients LEFT OUTER JOIN enter_ngos ON enter_ngos.client_id = clients.id LEFT OUTER JOIN client_enrollments on client_enrollments.client_id = clients.id LEFT OUTER JOIN exit_ngos ON exit_ngos.client_id = clients.id WHERE (enter_ngos.client_id IS NOT NULL AND enter_ngos.deleted_at IS NULL) AND exit_ngos.client_id IS NULL AND client_enrollments.client_id IS NULL AND clients.status = 'Active'"
    clients = ActiveRecord::Base.connection.execute(sql)

    if clients.to_a.present?
      update_sql = "UPDATE clients SET status = 'Accepted' WHERE clients.id IN (#{clients.values.join(',')});"
      ActiveRecord::Base.connection.execute(update_sql)
      puts "#{short_name}: Update status to Accepted to clients who only have Accepted NGO done!"
      puts "#{clients.values} done!"
    end
    puts ngo_client_ids_hash
  end
end
