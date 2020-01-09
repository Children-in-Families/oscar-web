namespace :client_slug do
  desc "TODO"
  task union: :environment do
    unioned_sql = Organization.where.not(short_name: 'shared').pluck(:short_name).map do |short_name|
      "(SELECT #{short_name}.clients.slug, #{short_name}.clients.archived_slug, '#{short_name}' organization_name, #{short_name}.clients.created_at FROM #{short_name}.clients)"
    end.join(" UNION ")
    sql = "SELECT * FROM (#{unioned_sql}) AS all_clients WHERE all_clients.slug IN (SELECT all_clients.slug FROM (#{unioned_sql}) AS all_clients GROUP BY all_clients.slug HAVING COUNT(all_clients.slug) > 1);"
    all_clients = ActiveRecord::Base.connection.execute(sql)

    all_clients.values.group_by{|values| values.first }.each do |slug, values|
      client_data = values.max_by{|value| value.last.to_datetime }
      short_name  = client_data[2]
      client_id   = client_data.first.split('-').last
      Organization.switch_to short_name
      client = Client.find_by(slug: slug)
      slug = client.generate_random_char
      Organization.switch_to short_name
      client.slug = "#{slug}-#{client.id}"
      # client.save(validate: false)
      puts "update client: (#{values.map(&:third).join('-')}) #{client.reload.slug}(#{short_name})"
      # Rake::Task["archived_slug:update"].invoke(short_name)
      # Rake::Task["client_to_shared:copy"].invoke(short_name)
      # Rake::Task["duplicate_checker_field:update"].invoke(short_name)
    end

    puts "Done!!!!"
  end

end
