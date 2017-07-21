module ClientEnrollmentHelper
  def redirect_path
    client = params[:client]
    (client.present? && program_streams.present?) ? request.referer : program_streams_path
  end
end
