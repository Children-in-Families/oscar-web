module ClientGridOptions
  extend ActiveSupport::Concern
  include ClientsHelper
  include FormBuilderHelper
  include AssessmentHelper
  include CarePlanHelper

  def choose_grid
    if current_user.admin? || current_user.strategic_overviewer?
      admin_client_grid
    elsif current_user.case_worker? || current_user.any_manager? || current_user.hotline_officer?
      non_admin_client_grid
    end
  end

  def client_columns_visibility
    return if params['commit'].blank?

    if params[:advanced_search_id]
      advanced_search = AdvancedSearch.find(params[:advanced_search_id])
      @client_columns = ClientColumnsVisibility.new(@client_grid, params.merge(advanced_search.field_visible).merge(column_form_builder: column_form_builder))
      @client_columns.visible_columns
    else
      @client_columns = ClientColumnsVisibility.new(@client_grid, params.merge(column_form_builder: column_form_builder))
      @client_columns.visible_columns
    end
  end

  def export_client_reports
    default_all_csi_assessments
    custom_all_csi_assessments
    if params[:client_advanced_search].present?
      custom_referral_data_report
      form_builder_report
    end
    csi_domain_score_report
    program_stream_report
    program_enrollment_date_report
    program_exit_date_report
    default_assessment_created_at
    default_date_of_assessments
    default_date_of_completed_assessments
    care_plan_date
    care_plan_completed_date
    care_plan_count
    custom_assessment_created_at
    custom_date_of_assessments
    default_date_of_completed_custom_assessments
    export_risk_assessment_columns
    case_note_date_report
    case_note_type_report
    accepted_date_report
    exit_date_report
    exit_note_report
    other_info_of_exit_report
    exit_circumstance_report
    exit_reasons_report
  end

  def exit_reasons_report
    return unless @client_columns.visible_columns[:exit_reasons_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:exit_reasons, header: I18n.t('datagrid.columns.clients.exit_reasons')) do |client|
        client.exit_ngos.most_recents.first&.exit_reasons.join(', ') if client.exit_ngos.any?
      end
    else
      @client_grid.column(:exit_reasons, header: I18n.t('datagrid.columns.clients.exit_reasons')) do |client|
        if client.exit_ngos.any?
          reasons = [ExitNgo::EXIT_REASONS.sort, I18n.t('client.exit_ngos.form.exit_reason_options').values].transpose.to_h
          results = ''
          client.exit_ngos.most_recents.each do |exit_ngo|
            results = exit_ngo.exit_reasons.map { |reason| reasons[reason] }.join(', ') if exit_ngo.exit_reasons.present?
          end
          results
        end
      end
    end
  end

  def exit_circumstance_report
    return unless @client_columns.visible_columns[:exit_circumstance_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:exit_circumstance, header: I18n.t('datagrid.columns.clients.exit_circumstance')) do |client|
        client.exit_ngos.most_recents.first&.exit_circumstance
      end
    else
      @client_grid.column(:exit_circumstance, header: I18n.t('datagrid.columns.clients.exit_circumstance')) do |client|
        client.exit_ngos.most_recents.pluck(:exit_circumstance).select(&:present?).join(', ') if client.exit_ngos.any?
      end
    end
  end

  def other_info_of_exit_report
    return unless @client_columns.visible_columns[:other_info_of_exit_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:other_info_of_exit, header: I18n.t('datagrid.columns.clients.other_info_of_exit')) do |client|
        client.exit_ngos.most_recents.first&.other_info_of_exit
      end
    else
      @client_grid.column(:other_info_of_exit, header: I18n.t('datagrid.columns.clients.other_info_of_exit')) do |client|
        client.exit_ngos.most_recents.pluck(:other_info_of_exit).select(&:present?).join(', ') if client.exit_ngos.any?
      end
    end
  end

  def exit_note_report
    return unless @client_columns.visible_columns[:exit_note_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:exit_note, header: I18n.t('datagrid.columns.clients.exit_note')) do |client|
        client.exit_ngos.most_recents.first&.exit_note
      end
    else
      @client_grid.column(:exit_note, header: I18n.t('datagrid.columns.clients.exit_note')) do |client|
        client.exit_ngos.most_recents.pluck(:exit_note).select(&:present?).join(', ') if client.exit_ngos.any?
      end
    end
  end

  def exit_date_report
    return unless @client_columns.visible_columns[:exit_date_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:exit_date, header: I18n.t('datagrid.columns.clients.ngo_exit_date')) do |client|
        client.exit_ngos.most_recents.first&.exit_date
      end
    else
      @client_grid.column(:exit_date, header: I18n.t('datagrid.columns.clients.ngo_exit_date')) do |client|
        date_filter(client.exit_ngos.most_recents, 'exit_date').map { |date| date.exit_date }.select(&:present?).join(', ') if client.exit_ngos.any?
      end
    end
  end

  def accepted_date_report
    return unless @client_columns.visible_columns[:accepted_date_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:accepted_date, header: I18n.t('datagrid.columns.clients.ngo_accepted_date')) do |client|
        client.enter_ngos.most_recents.first&.accepted_date
      end
    else
      @client_grid.column(:accepted_date, header: I18n.t('datagrid.columns.clients.ngo_accepted_date')) do |client|
        date_filter(client.enter_ngos.most_recents, 'accepted_date').map { |date| date.accepted_date }.select(&:present?).join(', ') if client.enter_ngos.any?
      end
    end
  end

  def program_stream_report
    return unless @client_columns.visible_columns[:program_streams_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:program_streams, header: I18n.t('datagrid.columns.clients.program_streams')) do |client|
        client.client_enrollments.active.last&.program_stream&.name
      end
    else
      @client_grid.column(:program_streams, header: I18n.t('datagrid.columns.clients.program_streams')) do |client|
        client.client_enrollments.active.map { |c| c.program_stream&.name }.uniq.join(', ')
      end
    end
  end

  def program_enrollment_date_report
    return unless @client_columns.visible_columns[:program_enrollment_date_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:program_enrollment_date, header: I18n.t('datagrid.columns.clients.program_enrollment_date')) do |client|
        recent_record = client.client_enrollments.active.order(enrollment_date: :desc).first
        "#{recent_record.program_stream.name} : #{recent_record.enrollment_date}" if recent_record
      end
    else
      @client_grid.column(:program_enrollment_date, header: I18n.t('datagrid.columns.clients.program_enrollment_date')) do |client|
        client.client_enrollments.active.map { |a| a.enrollment_date }.join(', ')
      end
    end
  end

  def program_exit_date_report
    return unless @client_columns.visible_columns[:program_exit_date_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:program_exit_date, header: I18n.t('datagrid.columns.clients.program_exit_date')) do |client|
        recent_record = client.client_enrollments.inactive.joins(:leave_program).order('leave_programs.exit_date DESC').first
        "#{recent_record.program_stream.name} : #{recent_record.leave_program.exit_date}" if recent_record.present?
      end
    else
      @client_grid.column(:program_exit_date, header: I18n.t('datagrid.columns.clients.program_exit_date')) do |client|
        client.client_enrollments.inactive.joins(:leave_program).map { |a| a.leave_program.exit_date }.join(', ')
      end
    end
  end

  def case_note_date_report
    return unless @client_columns.visible_columns[:case_note_date_].present?
    if params[:data].presence == 'recent'
      @client_grid.column(:case_note_date, header: I18n.t('datagrid.columns.clients.case_note_date')) do |client|
        date_format(client.case_notes.most_recents.order(meeting_date: :desc).first&.meeting_date)
      end
    else
      @client_grid.column(:case_note_date, header: I18n.t('datagrid.columns.clients.case_note_date')) do |client|
        case_note_query(client.case_notes.most_recents, 'case_note_date').map { |date| date_format(date.meeting_date) }.select(&:present?).join(', ') if client.case_notes.any?
      end
    end
  end

  def case_note_type_report
    return unless @client_columns.visible_columns[:case_note_type_].present?

    if params[:data].presence == 'recent'
      @client_grid.column(:case_note_type, header: I18n.t('datagrid.columns.clients.case_note_type')) do |client|
        client.case_notes.most_recents.order(meeting_date: :desc).first&.interaction_type
      end
    else
      @client_grid.column(:case_note_type, header: I18n.t('datagrid.columns.clients.case_note_type')) do |client|
        case_note_query(client.case_notes.most_recents, 'case_note_type').map(&:interaction_type).select(&:present?).join(', ') if client.case_notes.any?
      end
    end
  end

  def default_assessment_created_at
    return unless @client_columns.visible_columns[:assessment_created_at_].present?

    assessment_created_at('default')
  end

  def default_date_of_assessments
    return unless @client_columns.visible_columns[:date_of_assessments_].present?

    date_of_assessments('default')
  end

  def default_date_of_completed_assessments
    return unless @client_columns.visible_columns[:completed_date_].present?

    date_of_completed_assessments
  end

  def default_date_of_completed_custom_assessments
    return unless @client_columns.visible_columns[:custom_completed_date_].present?

    date_of_completed_cusotm_assessments
  end

  def custom_assessment_created_at
    return unless @client_columns.visible_columns[:custom_assessment_created_at_].present?

    assessment_created_at('custom')
  end

  def custom_date_of_assessments
    return unless @client_columns.visible_columns[:date_of_assessments_].present?

    date_of_assessments('custom')
  end

  def assessment_created_at(type)
    case type
    when 'default'
      records = 'client.assessments.defaults'
      column = 'assessment_created_at'
    when 'custom'
      records = 'client.assessments.customs'
      column = 'custom_assessment_created_at'
    end

    header_translation = I18n.t("datagrid.columns.clients.#{column}", assessment: I18n.t('clients.show.assessment'))
    if params[:data].presence == 'recent'
      @client_grid.column(column.to_sym, preload: :assessments, header: header_translation) do |client|
        assessment = eval(records).latest_record
        next unless assessment.presence?

        assessment.created_at.to_date.to_formatted_s
      end
    else
      @client_grid.column(column.to_sym, preload: :assessments, header: header_translation) do |client|
        assessments = eval(records).most_recents
        next unless assessments.any?

        date_filter(assessments, column).map { |a| a.created_at.to_date.to_formatted_s }.join(', ')
      end
    end
  end

  def date_of_assessments(type)
    case type
    when 'default'
      records = 'client.assessments.defaults'
      column = 'date_of_assessments'
    when 'custom'
      records = 'client.assessments.customs'
      column = 'date_of_custom_assessments'
    end

    header = I18n.t("datagrid.columns.clients.#{column}", assessment: I18n.t('clients.show.assessment'))

    if params[:data].presence == 'recent'
      @client_grid.column(column.to_sym, preload: :assessments, header: header) do |client|
        eval(records).latest_record&.assessment_date.to_date.to_formatted_s if eval(records).any?
      end
    else
      @client_grid.column(column.to_sym, preload: :assessments, header: header) do |client|
        date_filter(eval(records).most_recents, "#{column}").map { |a| a.created_at.to_date.to_formatted_s }.join(', ') if eval(records).any?
      end
    end
  end

  def date_of_completed_assessments
    records = 'client.assessments.defaults.completed'
    column = 'completed_date'

    if params[:data].presence == 'recent'
      @client_grid.column(column.to_sym, header: I18n.t('datagrid.columns.clients.assessment_completed_date', assessment: I18n.t('clients.show.assessment'))) do |client|
        eval(records).latest_record&.completed_date.to_date.to_formatted_s if eval(records).any?
      end
    else
      @client_grid.column(column.to_sym, header: I18n.t('datagrid.columns.clients.assessment_completed_date', assessment: I18n.t('clients.show.assessment'))) do |client|
        assessments = []
        if $param_rules
          basic_rules = $param_rules['basic_rules']
          basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
          results = mapping_assessment_query_rules(basic_rules).reject(&:blank?)
          query_string = get_assessment_query_string('client_id', results, 'completed_date', '', client.id, basic_rules)
          assessments = client.assessments.defaults.completed.where(query_string)
        else
          assessments = client.assessments.defaults.completed
        end
        date_filter(assessments, 'completed_date').map { |a| a.completed_date.to_date.to_formatted_s }.join(', ') if assessments.any?
      end
    end
  end

  def date_of_completed_cusotm_assessments
    records = 'client.assessments.customs.completed'
    column = 'custom_completed_date'

    if params[:data].presence == 'recent'
      @client_grid.column(column.to_sym, header: I18n.t('datagrid.columns.clients.assessment_custom_completed_date', assessment: I18n.t('clients.show.assessment'))) do |client|
        eval(records).latest_record&.completed_date.to_date.to_formatted_s if eval(records).any?
      end
    else
      @client_grid.column(column.to_sym, header: I18n.t('datagrid.columns.clients.assessment_custom_completed_date', assessment: I18n.t('clients.show.assessment'))) do |client|
        assessments = []
        if $param_rules
          basic_rules = $param_rules['basic_rules']
          basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
          results = mapping_assessment_query_rules(basic_rules).reject(&:blank?)
          query_string = get_assessment_query_string('client_id', results, 'completed_date', '', client.id, basic_rules)
          assessments = client.assessments.customs.completed.where(query_string)
        else
          assessments = client.assessments.customs.completed
        end
        date_filter(assessments, 'completed_date').map { |a| a.completed_date.to_date.to_formatted_s }.join(', ') if assessments.any?
      end
    end
  end

  def default_all_csi_assessments
    return unless params['type'] == 'basic_info' && (@client_columns && @client_columns.visible_columns[:all_csi_assessments_].present?)
    domain_score_report('default')
  end

  def custom_all_csi_assessments
    return unless params['type'] == 'basic_info' && (@client_columns && @client_columns.visible_columns[:all_custom_csi_assessments_].present?)
    domain_score_report('custom')
  end

  def domain_score_report(type)
    case type
    when 'default'
      records = 'client.assessments.defaults'
      column = 'all_csi_assessments'
    when 'custom'
      records = 'client.assessments.customs'
      column = 'all_custom_csi_assessments'
    end

    if params[:data].presence == 'recent'
      @client_grid.column(column.to_sym, header: t("datagrid.columns.clients.#{column}", assessment: I18n.t('clients.show.assessment'))) do |client|
        recent_assessment = eval(records).latest_record
        "#{recent_assessment.created_at} => #{recent_assessment.assessment_domains_score}" if recent_assessment.present?
      end
    else
      @client_grid.column(column.to_sym, header: t("datagrid.columns.clients.#{column}", assessment: I18n.t('clients.show.assessment'))) do |client|
        eval(records).map(&:basic_info).join("\x0D\x0A")
      end
    end
    @client_grid.column_names << column.to_sym if @client_grid.column_names.any?
  end

  def csi_domain_score_report
    Domain.order_by_identity.each do |domain|
      identity = domain.identity
      if domain.custom_domain
        column = "custom_#{domain.convert_identity}".to_sym
      else
        column = domain.convert_identity.to_sym
      end
      @client_grid.column(column, class: 'domain-scores', header: identity) do |client|
        assessment_domains = map_assessment_and_score(client, identity, domain.id)
        assessment_results = map_assessment_and_score(client, identity, domain.id)
        assessments = domain.custom_domain ? assessment_results.customs : assessment_results
        assessment_domains = assessments.includes(:assessment_domains).map { |assessment| assessment.assessment_domains.joins(:domain).where(domains: { identity: identity }) }.flatten.uniq

        assessment_domains.compact.map { |assessment_domain| assessment_domain.score }.compact.join(', ')
      end
    end
  end

  def export_risk_assessment_columns
    if @client_columns && @client_columns.visible_columns[:level_of_risk_].present?
      @client_grid.column(:level_of_risk, header: t('risk_assessments._attr.level_of_risk')) do |client|
        risk_assessment = client.risk_assessment
        assessments = [risk_assessment && "#{risk_assessment.level_of_risk.titleize} (PC)", *client.assessments.client_risk_assessments.pluck(:level_of_risk).map(&:titleize)].compact
        assessments.join(', ')
      end
    end

    return unless @client_columns && @client_columns.visible_columns[:date_of_risk_assessment_].present?

    @client_grid.column(:date_of_risk_assessment, header: t('risk_assessments._attr.assessment_date')) do |client|
      risk_assessment = client.risk_assessment
      assessments = [risk_assessment && "#{date_format(risk_assessment.assessment_date)} (PC)", *client.assessments.client_risk_assessments.pluck(:assessment_date).map { |assessment_date| date_format(assessment_date) }].compact
      assessments.join(', ')
    end
  end

  def custom_referral_data_report
    quantitative_type_readable_ids = current_user.quantitative_type_permissions.readable.pluck(:quantitative_type_id) unless current_user.nil?
    quantitative_types = QuantitativeType.joins(:quantitative_cases).where('quantitative_types.visible_on LIKE ?', '%client%').distinct
    quantitative_types.each do |quantitative_type|
      if current_user.nil? || quantitative_type_readable_ids.include?(quantitative_type.id)
        @client_grid.column(quantitative_type.name.to_sym, class: 'quantitative-type', header: -> { quantitative_type.name }) do |object|
          quantitative_type_values = object.quantitative_cases.where(quantitative_type_id: quantitative_type.id).pluck(:value)
          rule = get_rule(params, quantitative_type.name.squish)
          if rule.presence && rule.dig(:type) == 'date'
            quantitative_type_values = date_condition_filter(rule, quantitative_type_values).presence || quantitative_type_values
          elsif rule.presence
            quantitative_type_values = select_condition_filter(rule, quantitative_type_values.flatten).presence || quantitative_type_values
          end
          quantitative_type_values.join(', ')
        end
      end
    end
  end

  def form_builder_report
    data = params[:data].presence
    column_form_builder.each do |field|
      fields = field[:id].gsub('&qoute;', '"').split('__')
      rule = get_rule(params, fields.last)
      @client_grid.column(field[:id].to_sym, header: form_builder_format_header(fields)) do |client|
        format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        if fields.first == 'formbuilder'
          if data == 'recent'
            if fields.last == 'Has This Form'
              properties = client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client' }).count
            else
              properties = client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client' }).order(created_at: :desc).first&.properties
              properties = property_filter(properties, format_field_value)
              properties = format_array_value(properties[format_field_value]) if properties.present?
            end
          else
            if fields.last == 'Has This Form'
              properties = custom_form_with_has_form(client, fields).count
            else
              if $param_rules
                custom_field_id = client.custom_fields.find_by(form_title: fields.second)&.id
                basic_rules = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
                basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
                results = mapping_form_builder_param_value(basic_rules, 'formbuilder')
                query_string = get_query_string(results, 'formbuilder', 'custom_field_properties.properties')
                sql = query_string.reverse.reject(&:blank?).map { |sql| "(#{sql})" }.join(' AND ')

                custom_field_properties = client.custom_field_properties.where(custom_field_id: custom_field_id).where(sql).properties_by(format_field_value)
                custom_field_properties = custom_field_properties.blank? ? custom_form_with_has_form(client, fields).properties_by(format_field_value) : custom_field_properties
              else
                custom_field_properties = client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client' }).properties_by(format_field_value)
              end
              custom_field_properties = property_filter(custom_field_properties, format_field_value)
              custom_field_properties.map { |properties| check_is_string_date?(properties) }.join(', ')
            end
          end
        elsif fields.first == 'enrollmentdate'
          if data == 'recent'
            properties = client.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).order(enrollment_date: :desc).first&.enrollment_date
          else
            properties = date_filter(client.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }), fields.join('__')).map { |date| date.enrollment_date }
            properties = property_filter(properties, format_field_value)
            properties.join(', ')
          end
        elsif fields.first == 'enrollment'
          if data == 'recent'
            enrollment_properties = client.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).order(enrollment_date: :desc).first&.properties
            enrollment_properties = property_filter(enrollment_properties, format_field_value)
            enrollment_properties = format_array_value(enrollment_properties[format_field_value]) if enrollment_properties.present?
          else
            enrollment_properties = client.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).properties_by(format_field_value)
            enrollment_properties = property_filter(enrollment_properties, format_field_value)
            enrollment_properties.map { |properties| check_is_string_date?(properties) }.join(' | ')
          end
        elsif fields.first == 'tracking'
          ids = client.client_enrollments.ids
          if data == 'recent'
            enrollment_tracking_properties = ClientEnrollmentTracking.joins(:tracking).where(trackings: { name: fields.third }, client_enrollment_trackings: { client_enrollment_id: ids }).order(created_at: :desc).first&.properties
            enrollment_tracking_properties = format_array_value(enrollment_tracking_properties[format_field_value]) if enrollment_tracking_properties.present?
          else
            client_enrollment_trackings = ClientEnrollmentTracking.joins(:tracking).where(trackings: { name: fields.third }, client_enrollment_trackings: { client_enrollment_id: ids })
            properties = form_builder_query(client_enrollment_trackings, fields.first, field[:id].gsub('&qoute;', '"')).properties_by(format_field_value, client_enrollment_trackings)

            properties.map { |properties| check_is_string_date?(properties) }.join(', ')
          end
        elsif fields.first == 'exitprogramdate'
          ids = client.client_enrollments.inactive.ids
          if data == 'recent'
            properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).order(exit_date: :desc).first&.exit_date
          else
            properties = date_filter(LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }), fields.join('__')).map { |date| date.exit_date }
            properties = property_filter(properties, format_field_value)
            properties.join(', ')
          end
        elsif fields.first == 'exitprogram'
          ids = client.client_enrollments.inactive.ids
          if data == 'recent'
            leave_program_properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).order(exit_date: :desc).first&.properties
            leave_program_properties = property_filter(leave_program_properties, format_field_value)
            leave_program_properties = format_array_value(leave_program_properties[format_field_value]) if leave_program_properties.present?
          else
            leave_program_properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).properties_by(format_field_value)
            leave_program_properties = property_filter(leave_program_properties, format_field_value)
            leave_program_properties.map { |properties| check_is_string_date?(properties) }.join(', ')
          end
        end
      end
    end
  end

  def admin_client_grid
    data = params[:data].presence

    if params.dig(:client_grid, :quantitative_types).present?
      quantitative_types = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user, qType: quantitative_types, dynamic_columns: column_form_builder, param_data: data))
    else
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user, dynamic_columns: column_form_builder, param_data: data))
    end

    @client_grid.assessment_setting_id = assessment_setting_id
  end

  def non_admin_client_grid
    data = params[:data].presence

    if params.dig(:client_grid, :quantitative_types).present?
      quantitative_types = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user, qType: quantitative_types, dynamic_columns: column_form_builder, param_data: data))
    else
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user, dynamic_columns: column_form_builder, param_data: data))
    end

    @client_grid.assessment_setting_id = assessment_setting_id
  end

  def column_form_builder
    forms = []
    if @custom_form_fields.present?
      forms << @custom_form_fields
    elsif @wizard_custom_form_fields.present?
      forms << @wizard_custom_form_fields
    end

    if @program_stream_fields.present?
      forms << @program_stream_fields
    elsif @wizard_program_stream_fields.present?
      forms << @wizard_program_stream_fields
    end

    forms.flatten
  end

  def form_builder_params
    params[:form_builder].present? ? nil : column_form_builder
  end

  def assessment_setting_id
    params.dig(:client_advanced_search, :assessment_selected)&.gsub('[', '')&.gsub(']', '')
  end
end
