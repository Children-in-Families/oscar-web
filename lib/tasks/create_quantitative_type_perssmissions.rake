namespace :quantitative_type_permissions do
  desc 'Create quantitative type permissions'
  task create: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      User.where.not(roles: ['admin', 'strategic overviewer']).each do |user|
        QuantitativeType.all.each do |qt|
          user.quantitative_type_permissions.create(quantitative_type_id: qt.id)
        end
      end
    end
  end
end
