module GridsHelper
  def get_object_path(asset)
    return url_for([@client, asset]) if controller_name == 'progress_notes'
    return url_for([@case.client, @case, asset]) if controller_name == 'quarterly_reports'
    url_for(asset)
  end
end
