class MigrateInteratedDate < ActiveRecord::Migration
  def up
    if column_exists?(:organizations, :last_integrated_date)
      current = Apartment::Tenant.current
      Organization.switch_to current
  
      if Organization.current && Organization.current.integrated_date.present?
        puts "Update last integrated date for #{current} - last integrated date: #{Organization.current.integrated_date}"
        Organization.current.update!(last_integrated_date: Organization.current.integrated_date)
      end
    end
  end
end
