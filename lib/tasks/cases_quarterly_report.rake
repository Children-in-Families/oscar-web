namespace :cases_quarterly_report do
  desc "Backup cases quarterly report"
  SHORT_NAMES = %w[agh ahc auscam cccu cct cfi cif css cvcd cwd demo fco fsc fsi fts gca gct hfj holt icf isf kmo kmr mho mrs msl mtp my myan newsmile pepy public rok scc shk spo ssc tlc tmw tutorials voice wmo].freeze
  task backup: :environment do
    SHORT_NAMES.each do |short_name|
      system("PGPASSWORD=#{ENV['DATABASE_PASSWORD']} pg_dump -d #{ENV['RECOVERED_DATABASE_NAME']} -U #{ENV['DATABASE_USER']} -h #{ENV['DATABASE_HOST']} -p #{ENV['DATABASE_PORT']} -n #{short_name} -t #{short_name}.cases -t #{short_name}.case_contracts -t #{short_name}.quarterly_reports > #{short_name}_cases_production_#{Time.now.strftime("%Y-%m-%d")}.dump")
      puts "Backup #{short_name} Done!!!"
    end
  end

  task table_drop: :environment do
    SHORT_NAMES.each do |short_name|
      # next if Organization.find_by(short_name: short_name).nil? || short_name != 'cif'
      next unless short_name == 'cif'
      ActiveRecord::Base.connection.execute <<-SQL.squish
        DROP TABLE IF EXISTS "#{short_name}".quarterly_reports CASCADE;
        DROP TABLE IF EXISTS "#{short_name}".case_contracts CASCADE;
        DROP TABLE IF EXISTS "#{short_name}".cases CASCADE;
      SQL
      puts "Drop #{short_name} Done!!!"
    end
  end

  task restore: :environment do
    SHORT_NAMES.each do |short_name|
      # next if Organization.find_by(short_name: short_name).nil? || short_name != 'mtp'
      next unless short_name == 'cif'
      begin
        system("PGPASSWORD=#{ENV['DATABASE_PASSWORD']} psql #{ENV['DATABASE_NAME']} -U #{ENV['DATABASE_USER']} -h #{ENV['DATABASE_HOST']} -p #{ENV['DATABASE_PORT']} < #{short_name}_cases_production_2019-11-27.dump")
      rescue
        abort "!!! Failed to restore data from #{short_name}_cases_production_2019-11-27.dump} file."
      end
    end
  end
end
