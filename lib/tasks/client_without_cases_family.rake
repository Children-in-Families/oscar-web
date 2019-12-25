namespace :client_without_cases_family do
  desc "Attach family to client whos id was in family's children field"
  task restore: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'share'
      Organization.switch_to short_name
      family_ids = Family.ids
      PaperTrail::Version.where(item_type: 'Family', event: 'update', item_id: family_ids).where('object_changes iLIKE ? AND DATE(created_at) BETWEEN ? AND ?', "%\nchildren%", '2017-10-01', '2019-11-01').order(:created_at).group_by(&:item_id).each do |family_id, versions|
        version = versions.last
        if version.present?
          client_ids = version.changeset['children'].last
          if client_ids.compact.blank?
            previous_client_ids = version.changeset['children'].first
            sql = "
              UPDATE families SET children = '{}' WHERE families.id = #{family_id};
              UPDATE clients SET current_family_id = NULL WHERE clients.id IN (#{previous_client_ids.join(',')});
              UPDATE clients SET current_family_id = NULL  WHERE clients.current_family_id = #{family_id};
            ".squish
          else
            sql = "
              UPDATE families SET children = (select array_agg(distinct e) from unnest(array_cat(children, ARRAY#{client_ids})) e) WHERE families.id = #{family_id};
              UPDATE clients SET current_family_id = #{family_id} WHERE clients.id IN (#{client_ids.join(',')});".squish
          end

          ActiveRecord::Base.connection.execute(sql)
          puts "#{short_name}: #{client_ids}"
        end
      end

      family_client_ids = Family.where("array_upper(children, 1) is not null").pluck(:children).flatten
      values = Client.where(id: family_client_ids, current_family_id: nil).map do |client|
        family_id = Family.where('children && ARRAY[?]', client.id).last.id
        "(#{client.id}, #{family_id || 'NULL'})"
      end.join(", ")
      ActiveRecord::Base.connection.execute("UPDATE clients SET current_family_id = mapping_values.family_id FROM (VALUES #{values}) AS mapping_values (client_id, family_id) WHERE clients.id = mapping_values.client_id") if values.present?
      puts "client id in family.children Done!!!"

      client_values = Client.joins(:cases).where(current_family_id: nil).where.not(cases: { family_id: nil }).distinct.map do |client|
        family_id = client.cases.last.family.id
        "(#{client.id}, #{family_id || 'NULL'})"
      end.join(", ")
      sql = "
        UPDATE clients SET current_family_id = mapping_values.family_id FROM (VALUES #{client_values}) AS mapping_values (client_id, family_id) WHERE clients.id = mapping_values.client_id;
        UPDATE families SET children = array_append(children, mapping_values.client_id) FROM (VALUES #{client_values}) AS mapping_values (client_id, family_id) WHERE families.id = mapping_values.family_id;
      ".squish
      ActiveRecord::Base.connection.execute(sql) if client_values.present?

      family_client_values = Client.where(status: 'Active', current_family_id: nil).map do |client|
        versions = PaperTrail::Version.where(item_type: 'Family').where('object_changes iLIKE ?', "%\nchildren%{%#{client.id}%}%")
        next if versions.blank?
        family_id =  versions.last.item_id
        "(#{client.id}, #{family_id || 'NULL'})"
      end.compact.join(', ')

      sql = "
        UPDATE clients SET current_family_id = mapping_values.family_id FROM (VALUES #{family_client_values}) AS mapping_values (client_id, family_id) WHERE clients.id = mapping_values.client_id;
        UPDATE families SET children = array_append(children, mapping_values.client_id) FROM (VALUES #{family_client_values}) AS mapping_values (client_id, family_id) WHERE families.id = mapping_values.family_id;
      ".squish
      ActiveRecord::Base.connection.execute(sql) if family_client_values.present?
    end
  end

  task add_client_id_to_family: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'share'
      Organization.switch_to short_name
      sql = "UPDATE #{short_name}.families AS f SET children = array_append(children, c.id) FROM #{short_name}.clients AS c WHERE f.id = c.current_family_id AND (f.children @> ARRAY[c.id]) IS NOT TRUE;"
      result = ActiveRecord::Base.connection.execute(sql)
      puts "#{short_name}: #{result.cmd_status}"
    end
  end
end
