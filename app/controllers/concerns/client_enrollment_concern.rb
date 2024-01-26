module ClientEnrollmentConcern
  def client_enrollment_params
    if properties_params.present?
      mappings = {}
      properties_params.each do |k, v|
        mappings[k] = k.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('%22', '"')
      end
      formatted_params = properties_params.map {|k, v| [mappings[k], v] }.to_h
      formatted_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 }
    end
    default_params = params.require(:client_enrollment).permit(:enrollment_date).merge!(program_stream_id: params[:program_stream_id])
    default_params = default_params.merge!(properties: formatted_params) if formatted_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:client_enrollment][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
    default_params
  end

  def client_enrollment_index_path
    redirect_to client_client_enrollments_path(@client), alert: t('.client_not_valid')
  end

  def client_filtered
    return @client_filter if defined?(@client_filter)

    @client_filter, _query = AdvancedSearches::ClientAdvancedSearch.new(@program_stream.rules, Client.all).filter
    @client_filter
  end

  def ordered_program
    column = params[:order]
    descending = params[:descending] == 'true'
    if column.present? && column != 'status'
      ordered = program_stream_order_by_enrollment.sort_by{ |ps| ps.send(column).to_s.downcase }
      descending ? ordered.reverse : ordered
    elsif column.present? && column == 'status'
      descending ? program_stream_order_by_enrollment.reverse : program_stream_order_by_enrollment
    else
      program_stream_order_by_enrollment
    end
  end

  def valid_client?(client=nil)
    client_filtered.ids.include?(client ? client.id : @client.id)
  end

  def valid_program?
    program_active_status_ids   = ProgramStream.active_enrollments(@client).pluck(:id)
    if @program_stream.has_program_exclusive? && @program_stream.has_mutual_dependence?
      (@program_stream.program_exclusive & program_active_status_ids).empty? && (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.has_mutual_dependence?
      (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.has_program_exclusive?
      (@program_stream.program_exclusive & program_active_status_ids).empty?
    end
  end

  def find_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id])
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_program_stream
    @program_stream = ProgramStream.find(params[:program_stream_id])
  end

  def get_attachments
    @attachments = @client_enrollment.form_builder_attachments
  end

  def check_user_permission(permission)
    unless current_user.admin? || current_user.strategic_overviewer?
      permission_set = current_user.program_stream_permissions.find_by(program_stream_id: @program_stream.id)[permission]
      redirect_to root_path, alert: t('unauthorized.default') unless permission_set
    end
  end
end
