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

  task recover: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
      Client.includes(:enter_ngos).where(status: 'Accepted').references(:enter_ngos).group("clients.id, enter_ngos.id").having('COUNT(enter_ngos) = 0').each do |client|
        version = PaperTrail::Version.where(item_type: 'EnterNgo', event: 'create').where("versions.object_changes ILIKE '%client_id:\n- \n- #{client.id}\n%'").first
        if version
          attributes = version.changeset.map{|k,v| [k, v.last] if k != 'id' }.compact.to_h
          client.enter_ngos.create!(attributes)
          puts "NGO #{short_name} - updated client: #{client.slug}"
        end
      end
    end
  end

  task remove_duplicate: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      next if short_name != 'scc'
      Organization.switch_to short_name
      clients = Client.joins(:enter_ngos).group("clients.id, enter_ngos.created_at::date").having('COUNT(enter_ngos) > 1')
      next if clients.blank?
      clients.each do |client|
        enter_ngo_grouped_by_accepted_dates = client.enter_ngos.map{ |enter_ngo| [enter_ngo.id, enter_ngo.created_at.strftime("%Y-%m-%d")] }.group_by(&:second)
        enter_ngo_grouped_by_accepted_dates.each do |the_date, values|
          next if values.count == 1
          enter_ngos_ids = values.map(&:first)
          enter_ngos = client.enter_ngos.where(id: enter_ngos_ids)
          enter_ngos_id = enter_ngos.last.id
          enter_ngos.where.not(id: enter_ngos_id).delete_all
          puts client.slug
        end
      end
      puts short_name
    end
  end
end
