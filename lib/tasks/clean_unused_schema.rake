desc 'Clean unused schema'
task :clean_unused_schema => :environment do
  Organization.without_shared.only_deleted.each do |org|
    puts "================ Dropping schema #{org.short_name} ================"

    begin
      Apartment::Tenant.drop(org.short_name)
    rescue Apartment::TenantNotFound => e
      puts "================ Schema #{org.short_name} not found ================"
    end

    UsageReport.where(organization_id: org.id).destroy_all
    org.destroy_fully!
  end
end
