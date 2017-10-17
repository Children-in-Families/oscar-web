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
              CustomFieldPermission.create(user_id: user.id, custom_field_id: cf.id, readable: false, editable: false)
            else
              CustomFieldPermission.create(user_id: user.id, custom_field_id: cf.id, readable: true, editable: true)
            end
          end
        end

        unless user.program_stream_permissions.any?
          ProgramStream.all.each do |ps|
            ProgramStreamPermission.create(user_id: user.id, program_stream_id: ps.id, readable: false, editable: false)
          end
        end
      end
    end
  end
end
