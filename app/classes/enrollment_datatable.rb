class EnrollmentDatatable < ApplicationDatatable
  def initialize(view)
    @view = view
    @fetch_programs =  fetch_programs
  end

  def as_json(options = {})
    {
      recordsFiltered: total_entries,
      data: column_enrollments
    }
  end

  def fetch_programs
    ProgramStream.order(:name).page(page).per(per_page)
  end

  def column_enrollments
    @fetch_programs.map{ |p| [p.name, link_enrollment(p)] }
  end

  def link_enrollment(program_stream)
    link_to new_multiple_form_program_stream_client_enrollment_path(program_stream), class: 'btn btn-primary btn-sm' do
      I18n.t('dashboards.program_enrollment_tab.enroll')
    end
  end

  def total_entries
    @fetch_programs.total_count
  end
end
