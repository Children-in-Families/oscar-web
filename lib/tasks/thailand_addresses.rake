namespace :thailand_addresses do
  desc 'Thailand addresses import'
  task :import, [:short_name] => :environment do |task, args|
    sql = <<-SQL.squish
      DELETE FROM #{args.short_name}.provinces;
      DELETE FROM #{args.short_name}.districts;
      DELETE FROM #{args.short_name}.subdistricts;
    SQL

    ActiveRecord::Base.connection.execute(sql)

    sql = <<-SQL.squish
            INSERT INTO #{args.short_name}.provinces SELECT * FROM gca.provinces;
            INSERT INTO #{args.short_name}.districts SELECT * FROM gca.districts;
            INSERT INTO #{args.short_name}.subdistricts SELECT * FROM gca.subdistricts;
          SQL
    ActiveRecord::Base.connection.execute(sql)
  end
end
