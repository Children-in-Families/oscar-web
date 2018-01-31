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

  def export_client_reports
    domain_score_report
    form_builder_report if params[:client_advanced_search].present?
    csi_domain_score_report
    program_stream_report
    program_enrollment_date_report
    program_exit_date_report
    date_of_assessments
    form_title_report
    case_note_date_report
    case_note_type_report
  end

  def form_title_report
    return unless params[:form_title_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:form_title, header: I18n.t('datagrid.columns.clients.form_title')) do |client|
        client.custom_field_properties.order(created_at: :desc).first.try(:custom_field).try(:form_title)
      end
    else
      @client_grid.column(:form_title, header: I18n.t('datagrid.columns.clients.form_title')) do |client|
        client.custom_fields.pluck(:form_title).uniq.join(', ')
      end
    end
  end

  def program_stream_report
    return unless params[:program_streams_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:program_streams, header: I18n.t('datagrid.columns.clients.program_streams')) do |client|
        client.client_enrollments.last.try(:program_stream).try(:name)
      end
    else
      @client_grid.column(:program_streams, header: I18n.t('datagrid.columns.clients.program_streams')) do |client|
        client.client_enrollments.map{ |c| c.program_stream.name }.uniq.join(', ')
      end
    end
  end

  def program_enrollment_date_report
    return unless params[:program_enrollment_date_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:program_enrollment_date, header: I18n.t('datagrid.columns.clients.program_enrollment_date')) do |client|
        recent_record = client.client_enrollments.active.order(enrollment_date: :desc).first
        "#{recent_record.program_stream.name} : #{recent_record.enrollment_date}" if recent_record
      end
    else
      @client_grid.column(:program_enrollment_date, header: I18n.t('datagrid.columns.clients.program_enrollment_date')) do |client|
        client.client_enrollments.active.map{|a| a.enrollment_date }.join(' | ')
      end
    end
  end

  def program_exit_date_report
    return unless params[:program_exit_date_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:program_exit_date, header: I18n.t('datagrid.columns.clients.program_exit_date')) do |client|
        recent_record = client.client_enrollments.inactive.joins(:leave_program).order('leave_programs.exit_date DESC').first
        "#{recent_record.program_stream.name} : #{recent_record.leave_program.exit_date}" if recent_record.present?
      end
    else
      @client_grid.column(:program_exit_date, header: I18n.t('datagrid.columns.clients.program_exit_date')) do |client|
        client.client_enrollments.inactive.joins(:leave_program).map{|a| a.leave_program.exit_date }.join(' | ')
      end
    end
  end

  def case_note_date_report
    return unless params[:case_note_date_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:case_note_date, header: I18n.t('datagrid.columns.clients.case_note_date')) do |client|
        client.case_notes.most_recents.order(meeting_date: :desc).first.try(:meeting_date)
      end
    else
      @client_grid.column(:case_note_date, header: I18n.t('datagrid.columns.clients.case_note_date')) do |client|
        client.case_notes.most_recents.pluck(:meeting_date).select(&:present?).join(' | ') if client.case_notes.any?
      end
    end
  end

  def case_note_type_report
    return unless params[:case_note_type_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:case_note_type, header: I18n.t('datagrid.columns.clients.case_note_type')) do |client|
        client.case_notes.most_recents.order(meeting_date: :desc).first.try(:interaction_type)
      end
    else
      @client_grid.column(:case_note_type, header: I18n.t('datagrid.columns.clients.case_note_type')) do |client|
        client.case_notes.most_recents.pluck(:interaction_type).select(&:present?).join(' | ') if client.case_notes.any?
      end
    end
  end

  def date_of_assessments
    return unless params[:date_of_assessments_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:date_of_assessments, header: I18n.t('datagrid.columns.clients.date_of_assessments')) do |client|
        client.assessments.latest_record.try(:created_at).strftime('%d %B, %Y') if client.assessments.any?
      end
    else
      @client_grid.column(:date_of_assessments, header: I18n.t('datagrid.columns.clients.date_of_assessments')) do |client|
        client.assessments.most_recents.map{ |a| a.created_at.to_date }.join(' | ') if client.assessments.any?
      end
    end
  end

  def domain_score_report
    return unless params['type'] == 'basic_info' && params[:all_csi_assessments_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:all_csi_assessments, header: t('.all_csi_assessments')) do |client|
        recent_assessment = client.assessments.latest_record
        "#{recent_assessment.created_at.to_date} => #{recent_assessment.assessment_domains_score}" if recent_assessment.present?
      end
    else
      @client_grid.column(:all_csi_assessments, header: t('.all_csi_assessments')) do |client|
        client.assessments.map(&:basic_info).join("\x0D\x0A")
      end
    end
    @client_grid.column_names << :all_csi_assessments if @client_grid.column_names.any?
  end

  def csi_domain_score_report
    Domain.order_by_identity.each do |domain|
      identity = domain.identity
      @client_grid.column(domain.convert_identity.to_sym, class: 'domain-scores', header: identity) do |client|
        assessment = client.assessments.latest_record
        assessment.assessment_domains.find_by(domain_id: domain.id).try(:score) if assessment.present?
      end
    end
  end

  def form_builder_report
    data = params[:data].presence
    column_form_builder.each do |field|
      fields = field[:id].split('_')
      @client_grid.column(field[:id].to_sym, header: form_builder_format_header(fields)) do |client|
        format_field_value = fields.last.gsub(/\[/, '&#91;').gsub(/\]/, '&#93;')
        if fields.first == 'formbuilder'
          if data == 'recent'
            properties = client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client'}).order(created_at: :desc).first.try(:properties)
            properties = format_array_value(properties[format_field_value]) if properties.present?
          else
            custom_field_properties = client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client'}).properties_by(format_field_value)
            custom_field_properties.map{ |properties| format_properties_value(properties) }.join("\n")
          end
        elsif fields.first == 'enrollment'
          if data == 'recent'
            enrollment_properties = client.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).order(enrollment_date: :desc).first.try(:properties)
            enrollment_properties = format_array_value(enrollment_properties[format_field_value]) if enrollment_properties.present?
          else
            enrollment_properties = client.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).properties_by(format_field_value)
            enrollment_properties.map{ |properties| format_properties_value(properties) }.join("\n")
          end
        elsif fields.first == 'tracking'
          ids = client.client_enrollments.ids
          if data == 'recent'
            enrollment_tracking_properties = ClientEnrollmentTracking.joins(:tracking).where(trackings: { name: fields.third }, client_enrollment_trackings: { client_enrollment_id: ids }).order(created_at: :desc).first.try(:properties)
            enrollment_tracking_properties = format_array_value(enrollment_tracking_properties[format_field_value]) if enrollment_tracking_properties.present?
          else
            enrollment_tracking_properties = ClientEnrollmentTracking.joins(:tracking).where(trackings: { name: fields.third }, client_enrollment_trackings: { client_enrollment_id: ids }).properties_by(format_field_value)
            enrollment_tracking_properties.map{ |properties| format_properties_value(properties) }.join("\n")
          end
        elsif fields.first == 'exitprogram'
          ids = client.client_enrollments.inactive.ids
          if data == 'recent'
            leave_program_properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).order(exit_date: :desc).first.try(:properties)
            leave_program_properties = format_array_value(leave_program_properties[format_field_value]) if leave_program_properties.present?
          else
            leave_program_properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).properties_by(format_field_value)
            leave_program_properties.map{ |properties| format_properties_value(properties) }.join("\n")
          end
        end
      end
    end
  end

  def admin_client_grid
    data = params[:data].presence
    if params.dig(:client_grid, :quantitative_types)
      quantitative_types = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(qType: quantitative_types, dynamic_columns: column_form_builder, param_data: data))
    else
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(dynamic_columns: column_form_builder, param_data: data))
    end
  end

  def non_admin_client_grid
    if params.dig(:client_grid, :quantitative_types)
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
