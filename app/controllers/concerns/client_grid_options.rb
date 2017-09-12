module ClientGridOptions
  extend ActiveSupport::Concern
  include ClientsHelper

  def choose_grid
    if current_user.admin? || current_user.strategic_overviewer?
      admin_client_grid
    elsif current_user.case_worker? || current_user.any_manager?
      non_admin_client_grid
    end
  end

  def columns_visibility
    @client_columns ||= ClientColumnsVisibility.new(@client_grid, params.merge(column_form_builder: column_form_builder))
    @client_columns.visible_columns
  end

  def domain_score_report
    return unless params['type'] == 'basic_info'
    @client_grid.column(:assessments, header: t('.assessments')) do |client|
      client.assessments.map(&:basic_info).join("\x0D\x0A")
    end
    @client_grid.column_names << :assessments if @client_grid.column_names.any?
  end

  def csi_domain_score_report
    if params[:controller] != 'clients'
      Domain.order_by_identity.each do |domain|
        identity = domain.identity
        @client_grid.column(domain.convert_identity.to_sym, class: 'domain-scores', header: identity) do |client|
          assessment = client.assessments.last
          assessment.assessment_domains.where(domain_id: domain.id).pluck(:score).first
        end
      end
    end
  end

  def form_builder_report
    column_form_builder.each do |field|
      fields = field[:id].split('_')
      @client_grid.column(field[:id].downcase.parameterize('_').to_sym, header: form_builder_format_header(fields)) do |client|
        if fields.first == 'formbuilder'
          custom_field_properties = client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client'}).properties_by(fields.last)
          custom_field_properties.map{ |properties| format_properties_value(properties) }.join("\n")
        elsif fields.first == 'enrollment'
          enrollment_properties = client.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).properties_by(fields.last)
          enrollment_properties.map{ |properties| format_properties_value(properties) }.join("\n")
        elsif fields.first == 'tracking'
          ids = client.client_enrollments.ids
          enrollment_tracking_properties = ClientEnrollmentTracking.joins(:tracking).where(trackings: { name: fields.third }, client_enrollment_trackings: { client_enrollment_id: ids }).properties_by(fields.last)
          enrollment_tracking_properties.map{ |properties| format_properties_value(properties) }.join("\n")
        elsif fields.first == 'exitprogram'
          ids = client.client_enrollments.inactive.ids
          leave_program_properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).properties_by(fields.last)
          leave_program_properties.map{ |properties| format_properties_value(properties) }.join("\n")
        end
      end
    end
  end

  def admin_client_grid
    if params[:client_grid] && params[:client_grid][:quantitative_types]
      quantitative_types = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(qType: quantitative_types, dynamic_columns: column_form_builder))
    else
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(dynamic_columns: column_form_builder))
    end
  end

  def non_admin_client_grid
    if params[:client_grid] && params[:client_grid][:quantitative_types]
      quantitative_types = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user, qType: quantitative_types, dynamic_columns: column_form_builder))
    else

      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user, dynamic_columns: column_form_builder))
    end
  end

  def column_form_builder
    if @custom_form_fields.present? || @program_stream_fields.present?
      @custom_form_fields + @program_stream_fields
    else
      []
    end
  end

  def form_builder_params
    params[:form_builder].present? ? nil : column_form_builder
  end
end
