namespace :organization_types do
  desc 'Create Organization Types'
  task create: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Partner.where.not(archive_organization_type: '').pluck(:archive_organization_type).uniq.each do |organization_type|
        OrganizationType.create(name: organization_type)
      end

      Partner.where.not(archive_organization_type: '').each do |partner|
        partner_organization_type = partner.archive_organization_type
        organization_type = OrganizationType.find_by(name: partner_organization_type)
        partner.organization_type_id = organization_type.id
        partner.save
      end
    end
  end
end
