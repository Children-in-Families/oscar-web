namespace :user_permission do
  desc 'Create user permissions'
  task create: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      
      User.all.each do |user|
        next if user.admin? || user.strategic_overviewer?
        unless user.permission.present?
          Permission.create(user: user, case_notes_readable: true, case_notes_editable: true, assessments_editable: true, assessments_readable: true)
        end

        unless user.custom_field_permissions.any?
          CustomField.all.each do |cf|
            if user.case_worker?
              user.custom_field_permissions.create(custom_field_id: cf.id)
            else
              user.custom_field_permissions.create(custom_field_id: cf.id, readable: true, editable: true)
            end
          end
        end

        unless user.program_stream_permissions.any?
          ProgramStream.all.each do |ps|
            user.program_stream_permissions.create(program_stream_id: ps.id)
          end
        end
      end
    end
  end
end
