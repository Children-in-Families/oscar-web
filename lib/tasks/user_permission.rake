namespace :users_permission do
  desc 'create user permission'
  task create: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      user_ids = User.includes(:permission).where.not(id: User.joins(:permission).ids).ids

      user_ids.each do |id|
        user = User.find(id)
        next if user.strategic_overviewer?
        user.create_permission

        CustomField.all.each do |cf|
          user.custom_field_permissions.find_or_create_by(custom_field_id: cf.id)
        end

        ProgramStream.all.each do |ps|
          user.program_stream_permissions.find_or_create_by(program_stream_id: ps.id)
        end

        QuantitativeType.all.each do |qt|
          user.quantitative_type_permissions.find_or_create_by(quantitative_type_id: qt.id)
        end
      end
    end
  end
end
