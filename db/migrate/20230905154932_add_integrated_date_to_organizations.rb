class AddIntegratedDateToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :last_integrated_date, :date

    current = Apartment::Tenant.current
    Organization.switch_to current

    if Organization.current && Organization.current.integrated_date.present?
      puts "Update last integrated date for #{current} - last integrated date: #{Organization.current.integrated_date}"
      Organization.current.update!(last_integrated_date: Organization.current.integrated_date)
    end
  end
end
