namespace :global_services_fk_contrain do
  desc "Remove global service global_services_fk_contrain"
  task :remove, [:tenant] => [:environment] do |task, args|
    if args[:tenant]
      puts "================= Drop contrain in: #{args[:tenant]} ========================="
      drop_constrain(args[:tenant])
    else
      Organization.all.each do |org|
        puts "================= Drop contrain in: #{org.short_name} ========================="
        drop_constrain(org.short_name)
      end
    end
  end

end

def drop_constrain(short_name)
  ActiveRecord::Base.connection.execute <<-SQL.squish
    ALTER TABLE IF EXISTS #{short_name}.global_services DROP CONSTRAINT IF EXISTS fk_rails_dd8845518e;
  SQL
end
