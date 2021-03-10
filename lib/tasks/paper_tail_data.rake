namespace :paper_tail_data do
  desc "Restore backup..."
  task restore: :environment do
    Organization.visible.pluck(:short_name).each do |short_name|
      # next unless short_name == 'demo'
      sql = "DROP TABLE IF EXISTS #{short_name}.version_associations, #{short_name}.versions CASCADE;".squish
      ActiveRecord::Base.connection.execute(sql)
      if !Rails.env.development?
        host_endpoint = ENV['DATABASE_HOST']
        database_name = ENV['DATABASE_NAME']
        database_user = ENV['DATABASE_USER']
      else
        host_endpoint = '127.0.0.1'
        database_name = 'oscar_web_development'
      end
      system("PGPASSWORD=#{ENV['DATABASE_PASSWORD']} psql #{database_name} -U #{database_user} -h #{host_endpoint} < #{short_name}_production_2021_03_09.dump")
    end
  end

  desc "Recreate case worker backup..."
  task recreate_case_worker_client: :environment do
    attribute_arry = %i[id user_id client_id]
    Organization.visible.pluck(:short_name).each do |short_name|
      # next unless short_name == 'demo'
      Apartment::Tenant.switch short_name
      PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'create').each do |version|
        attributes = attribute_arry.zip(version.changeset.slice(:id, :user_id, :client_id).values.flatten.compact).to_h
        deleted_version = PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'destroy').where(item_id: version.item_id).first
        if User.exists?(attributes[:user_id]) && Client.exists?(attributes[:client_id]) && !CaseWorkerClient.exists?(attributes[:id])
          if deleted_version&.created_at
            CaseWorkerClient.create({ **attributes, deleted_at: deleted_version&.created_at })
          else
            CaseWorkerClient.create(attributes).destroy
          end
        end
      end
    end
  end
end
