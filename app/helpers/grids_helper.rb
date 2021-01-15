module GridsHelper
  def get_object_path(asset)
    return url_for([@client, asset]) if controller_name == 'progress_notes'
    return url_for([@case.client, @case, asset]) if controller_name == 'quarterly_reports'
    return url_for(@program_stream) if controller_name.in?(%w(client_enrollment_trackings client_enrolled_program_trackings enrollment_trackings enrolled_program_trackings))
    url_for(asset)
  end
end
