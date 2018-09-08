namespace :update_organization_country do
  desc 'Update Organization country'
  task start: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      country = Setting.first.try(:country_name)
      org.update(country: country)
    end
  end
end
