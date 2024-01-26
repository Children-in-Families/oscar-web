desc 'Generate billable report for all organizations from client/family data'
task monthly_billable_report: :environment do
  Organization.where(onboarding_status: 'completed').without_shared.each do |org|
    Organization.switch_to org.short_name
    puts "Generating billable report for #{org.short_name}"

    report = BillableReport.find_or_create_by!(
      month: Date.current.month,
      year: Date.current.year,
      organization: Organization.current
    )

    # Accepted clients
    Client.accepted.without_test_clients.each do |client|
      next if report.billable_report_items.exists?(billable: client)

      version = client.versions.select(&:changed_to_status_accepted?).last
      
      unless version
        # Fix missing version from old code that does not create version
        version = client.versions.create!(
          event: 'update',
          whodunnit: 'System',
          object: client.attributes,
          object_changes: {
            'status' => ['Referred', 'Accepted']
          }
        )
      end

      version.assign_billable_report
    end

    # Active clients
    Client.active_status.without_test_clients.each do |client|
      next if report.billable_report_items.exists?(billable: client)

      version = client.versions.select(&:changed_to_status_active?).last

      unless version
        # Fix missing version from old code that does not create version
        version = client.versions.create!(
          event: 'update',
          whodunnit: 'System',
          object: client.attributes,
          object_changes: {
            'status' => ['Accepted', 'Active']
          }
        )
      end

      version.assign_billable_report
    end

    # Accepted family
    Family.where(status: 'Accepted').each do |family|
      next if report.billable_report_items.exists?(billable: family)

      version = family.versions.select(&:changed_to_status_accepted?).last

      unless version
        # Fix missing version from old code that does not create version
        version = family.versions.create!(
          event: 'update',
          whodunnit: 'System',
          object: family.attributes,
          object_changes: {
            'status' => ['Referred', 'Accepted']
          }
        )
      end

      version.assign_billable_report
    end

    # Active Family
    Family.where(status: 'Active').each do |family|
      next if report.billable_report_items.exists?(billable: family)

      version = family.versions.select(&:changed_to_status_active?).last

      unless version
        # Fix missing version from old code that does not create version
        version = family.versions.create!(
          event: 'update',
          whodunnit: 'System',
          object: family.attributes,
          object_changes: {
            'status' => ['Accepted', 'Active']
          }
        )
      end

      version.assign_billable_report
    end
  end
end
