module EnrollmentConcern
  def enrollment_params
    if entity_properties_params.present?
      mappings = {}
      entity_properties_params.each do |k, v|
        mappings[k] = k.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('%22', '"')
      end
      formatted_params = entity_properties_params.map {|k, v| [mappings[k], v] }.to_h
      formatted_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 }
    end
    default_params = params.require(:enrollment).permit(:enrollment_date).merge!(program_stream_id: params[:program_stream_id])
    default_params = default_params.merge!(properties: formatted_params) if formatted_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:enrollment][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
    default_params
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

  def find_entity
    if params[:family_id].present?
      @programmable = Family.includes(enrollments: [:program_stream]).find(params[:family_id])
    end
  end

  def find_program_stream
    @program_stream = ProgramStream.find(params[:program_stream_id])
  end

  def enrollment_index_path
    if params[:family_id]
      redirect_to family_enrollments_path(@programmable), alert: t('.not_valid')
    end
  end

  def entity_filtered
    if params[:family_id]
      @entity_filter ||= AdvancedSearches::Families::FamilyAdvancedSearch.new(@program_stream.rules, Family.all).filter
    end
  end

  def valid_entity?(programmable=nil)
    entity_filtered.ids.include?(programmable ? programmable.id : @programmable.id)
  end

  def valid_program?
    program_active_status_ids   = ProgramStream.active_enrollments(@programmable).pluck(:id)
    if @program_stream.has_program_exclusive? && @program_stream.has_mutual_dependence?
      (@program_stream.program_exclusive & program_active_status_ids).empty? && (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.has_mutual_dependence?
      (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.has_program_exclusive?
      (@program_stream.program_exclusive & program_active_status_ids).empty?
    end
  end

  def find_enrollment
    @enrollment = @programmable.enrollments.find(params[:id])
  end
end
