class AddOrganizationNameToUsageReports < ActiveRecord::Migration
  def change
    add_column :usage_reports, :organization_name, :string
    add_column :usage_reports, :organization_short_name, :string

    reversible do |dir|
      dir.up do
        org = Organization.find_by(short_name: Apartment::Tenant.current)
        return if org.nil?

        puts "Updating usage reports for #{org.full_name} (#{org.short_name})"

        UsageReport.where(organization_id: org.id).update_all(organization_name: org.full_name, organization_short_name: org.short_name)
      end
    end
  end
end
