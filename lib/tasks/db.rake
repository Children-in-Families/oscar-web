namespace :db do

  desc "Dumps the database to db/APP_NAME.dump"
  task :dump => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_dump -n public --column-inserts -a --verbose --no-acl -h #{host} -d #{db} > #{Rails.root}/db/#{app}_#{Rails.env}_pg.dump"
    end
    puts cmd
    exec cmd
  end

  desc "Update search_path to copy schema"
  task :update_search_path => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "sed 's/SET search_path =/SET search_path to public,/' < #{Rails.root}/db/#{app}_#{Rails.env}_pg.dump > #{Rails.root}/db/#{app}_#{Rails.env}_updated_path_pg.dump"
    end
    puts cmd
    exec cmd
  end

  desc "Restores the database dump at db/APP_NAME.dump."
  task :restore => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "psql #{db} < #{Rails.root}/db/#{app}_#{Rails.env}_updated_path_pg.dump"
    end
    puts cmd
    exec cmd
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username],
      ActiveRecord::Base.connection_config[:password]
  end
end
