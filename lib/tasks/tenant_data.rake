namespace :tenant_data do
  desc "Clean data in specific tenant including drop schema and backup"
  task :clean, [:short_name] => :environment do |task, args|
    short_name = args.short_name
    unless Rails.env.production?
      Apartment::Tenant.drop(short_name)
      puts "Drop schema done!!!"
      sql = "DELETE FROM shared.shared_clients WHERE shared.shared_clients.archived_slug iLIKE '#{short_name}-%';"
      ActiveRecord::Base.connection.execute(sql)
      puts "Clean shared_clients done!"
      system("PGPASSWORD=#{ENV['DATABASE_PASSWORD']} psql #{ENV['DATABASE_NAME']} -U #{ENV['DATABASE_USER']} -h #{ENV['DATABASE_HOST']} -p #{ENV['DATABASE_PORT']} < #{short_name}_production_2021_03_15_copy.dump")
      puts "Restore schema done!!!"
      Rake::Task["rake:db:migrate"].invoke()
      puts "Migration done!!!"
      # Rake::Task["cases_quarterly_report:table_drop"].invoke()
      puts "Drop cases !!!"
      # Rake::Task["cases_quarterly_report:restore"].invoke()
      puts "Restore cases done!!!"
      puts "Fake client info start!!!"
      Rake::Task["fake_client_info:update"].invoke(args.short_name)
      Rake::Task["archived_slug:update"].invoke(args.short_name)
      Rake::Task["client_to_shared:copy"].invoke(args.short_name)
      puts "duplicate_checker_field start!!!"
      Rake::Task["duplicate_checker_field:update"].invoke(args.short_name)
      Rake::Task["field_settings:import"].invoke(args.short_name)
      #Rake::Task["client_status:correct"].invoke()
      puts "Clean data done!!!"
    end
  end
end
