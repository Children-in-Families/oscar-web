namespace :forms_permission do
  desc "Create Custom Form and CPS permissions for all non strategic overviewer users"
  task create: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      User.where.not(roles: 'strategic overviewer').each do |user|
        ProgramStream.all.each do |program|
          program.program_stream_permissions.find_or_create_by(user: user)
        end
        CustomField.all.each do |custom_field|
          custom_field.custom_field_permissions.find_or_create_by(user_id: user.id)
        end
      end
    end
  end
end
