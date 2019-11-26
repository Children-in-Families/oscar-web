namespace :cases_quarterly_report do
  desc "Backup cases quarterly report"
  task backup: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      system("PGPASSWORD=#{ENV['DATABASE_PASSWORD']} pg_dump -d #{ENV['DATABASE_NAME']} -U #{ENV['DATABASE_USER']} -h #{ENV['DATABASE_HOST']} -p #{ENV['DATABASE_PORT']} -n #{short_name} -t #{short_name}.cases -t #{short_name}.case_contracts -t #{short_name}.quarterly_reports > #{short_name}_cases_production_#{Time.now.strftime("%Y-%m-%d")}.dump")
      puts "Backup #{short_name} Done!!!"
    end
  end

  task table_drop: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      ActiveRecord::Base.connection.execute <<-SQL.squish
        DROP TABLE IF EXISTS "#{short_name}".quarterly_reports CASCADE;
        DROP TABLE IF EXISTS "#{short_name}".case_contracts CASCADE;
        DROP TABLE IF EXISTS "#{short_name}".cases CASCADE;
      SQL
      puts "Drop #{short_name} Done!!!"
    end
  end

  task restore: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      begin
        system("PGPASSWORD=#{ENV['DATABASE_PASSWORD']} psql #{ENV['DATABASE_NAME']} -U #{ENV['DATABASE_USER']} -h #{ENV['DATABASE_HOST']} -p #{ENV['DATABASE_PORT']} < #{short_name}_cases_production_#{Time.now.strftime("%Y-%m-%d")}.dump")
      rescue
        abort "!!! Failed to restore data from #{short_name}_cases_production_#{Time.now.strftime("%Y-%m-%d")}.dump} file."
      end
    end
  end

end
