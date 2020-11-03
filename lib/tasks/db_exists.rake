namespace :db do
  desc "Checks to see if the database exists"
  task :exists do
    begin
      Rake::Task['environment'].invoke
      ActiveRecord::Base.connection
      raise "Organization Table does not exist!" unless Organization.table_exists?
    rescue
      puts "The database needs to be (re)created and schema loaded"
      exit 1
    else
      puts "The database exists and appears to be ready"
      exit 0
    end
  end
end
