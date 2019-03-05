namespace :quantitative_type_permissions do
  desc 'Create quantitative type permissions'
  task create: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      User.non_strategic_overviewers.each do |user|
        QuantitativeType.all.each do |qt|
          user.quantitative_type_permissions.find_or_create_by(quantitative_type_id: qt.id)
        end
      end
    end
  end
end
