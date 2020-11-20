module EnrollmentHelper
  def report_link_view(program_stream, entity_type = nil)
    if program_stream.enrollments.enrollments_by(@programmable).order(:created_at).last.try(:status) == 'Exited'
      if entity_type == 'Family'
        link_to t('.view'), report_family_enrollments_path(@programmable, program_stream_id: program_stream)
      end
    end
  end

  def enrollment_new_link(program_stream, entity_type = nil)
    path = entity_type == 'Family' ? new_family_enrollment_path(@programmable, program_stream_id: program_stream.id) : '#'
    if program_permission_editable?(program_stream) && policy(@programmable).create?
      link_to path do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width' do 
          t('.enroll')
        end
      end
    else
      link_to_if false, path do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width disabled' do 
          t('.enroll')
        end
      end
    end
  end
end
