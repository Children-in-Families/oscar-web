module FamilyAdvancedSearchesConcern
  extend ActiveSupport::Concern
  include ClientsHelper
  include AssessmentHelper

  def advanced_search
    basic_rules  = JSON.parse @basic_filter_params
    $param_rules = nil
    $param_rules = find_params_advanced_search
    @families    = AdvancedSearches::Families::FamilyAdvancedSearch.new(basic_rules, Family.accessible_by(current_ability)).filter
    custom_form_column
    respond_to do |f|
      f.html do
        @results                = @family_grid.scope { |scope| scope.where(id: @families.ids) }.assets.size
        @family_grid.scope { |scope| scope.where(id: @families.ids).page(params[:page]).per(20) }
      end
      f.xls do
        @family_grid.scope { |scope| scope.where(id: @families.ids) }
        export_family_reports
        send_data @family_grid.to_xls, filename: "family_report-#{Time.now}.xls"
      end
    end
  end

  def format_search_params
    advanced_search_params = params[:family_advanced_search]
    family_grid_params = params[:family_grid]
    return unless (advanced_search_params.is_a? String) || (family_grid_params.is_a? String)

    params[:family_advanced_search] = Rack::Utils.parse_nested_query(advanced_search_params)
    params[:family_grid] = Rack::Utils.parse_nested_query(family_grid_params)
  end

  def export_family_reports
    custom_all_csi_assessments
    if params[:client_advanced_search].present?
      form_builder_report
    end
    csi_domain_score_report
    default_date_of_completed_assessments
    custom_date_of_assessments
    case_note_date_report
    case_note_type_report
  end

  def build_advanced_search
    @advanced_search = AdvancedSearch.new
  end

  def custom_form_column
    @custom_form_columns = custom_form_fields.group_by{ |field| field[:optgroup] }
  end

  def get_custom_form
    form_ids = CustomFieldProperty.where(custom_formable_type: 'Family').pluck(:custom_field_id).uniq
    @custom_fields = CustomField.where(id: form_ids).order_by_form_title
  end

  def family_builder_fields
    @builder_fields = get_family_basic_fields + custom_form_fields
  end

  def get_family_basic_fields
    AdvancedSearches::Families::FamilyFields.new(user: current_user, pundit_user: pundit_user).render
  end

  def custom_form_values
    custom_form_value? ? eval(@advanced_search_params[:custom_form_selected]) : []
  end

  def custom_form_fields
    @custom_form_fields = get_custom_form_fields + get_has_this_form_fields
  end

  def get_has_this_form_fields
    @has_this_form_fields = AdvancedSearches::HasThisFormFields.new(custom_form_values).render
  end

  def get_custom_form_fields
    @custom_forms = AdvancedSearches::CustomFields.new(custom_form_values).render
  end

  def custom_form_value?
    @advanced_search_params.present? && @advanced_search_params[:custom_form_selected].present?
  end

  def has_params?
    @advanced_search_params.present? && @advanced_search_params[:basic_rules].present?
  end

  def find_params_advanced_search
    @advanced_search_params = params[:family_advanced_search]
  end

  def basic_params
    @basic_filter_params  = @advanced_search_params[:basic_rules]
  end

  def form_builder_report
    @custom_form_fields.each do |field|
      fields = field[:id].split('__')
      @family_grid.column(field[:id].to_sym, header: form_builder_format_header(fields)) do |family|
        if fields.last == 'Has This Form'
          custom_field_properties = family.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Family'}).count
        else
          format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
          custom_field_properties = family.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Family'}).properties_by(format_field_value)
          custom_field_properties.map{ |properties| format_properties_value(properties) }.join(' | ')
        end
      end
    end
  end

  def case_note_date_report
    return unless @family_columns.visible_columns[:case_note_date_].present?
    if params[:data].presence == 'recent'
      @family_grid.column(:case_note_date, header: I18n.t('datagrid.columns.clients.case_note_date')) do |family|
        family.case_notes.most_recents.order(meeting_date: :desc).first.try(:meeting_date)
      end
    else
      @family_grid.column(:case_note_date, header: I18n.t('datagrid.columns.clients.case_note_date')) do |family|
        case_note_query(family.case_notes.most_recents, 'case_note_date').map{|date| date.meeting_date }.select(&:present?).join(', ') if family.case_notes.any?
      end
    end
  end

  def case_note_type_report
    return unless @family_columns.visible_columns[:case_note_type_].present?
    if params[:data].presence == 'recent'
      @family_grid.column(:case_note_type, header: I18n.t('datagrid.columns.clients.case_note_type')) do |family|
        family.case_notes.most_recents.order(meeting_date: :desc).first.try(:interaction_type)
      end
    else
      @family_grid.column(:case_note_type, header: I18n.t('datagrid.columns.clients.case_note_type')) do |family|
        case_note_query(family.case_notes.most_recents, 'case_note_type').map(&:interaction_type).select(&:present?).join(', ') if family.case_notes.any?
      end
    end
  end

  def default_date_of_completed_assessments
    return unless @family_columns.visible_columns[:assessment_completed_date_].present?
    date_of_completed_assessments
  end

  def custom_date_of_assessments
    return unless @family_columns.visible_columns[:date_of_custom_assessments_].present?
    date_of_assessments('custom')
  end

  def date_of_assessments(type)
    case type
    when 'default'
      records = 'family.assessments.defaults'
      column = 'date_of_assessments'
    when 'custom'
      records = 'family.assessments.customs'
      column = 'date_of_custom_assessments'
    end

    if params[:data].presence == 'recent'
      @family_grid.column(column.to_sym, header: I18n.t("datagrid.columns.#{column}", assessment: I18n.t('families.show.assessment'))) do |family|
        eval(records).latest_record.try(:created_at).to_date.to_formatted_s if eval(records).any?
      end
    else
      @family_grid.column(column.to_sym, header: I18n.t("datagrid.columns.#{column}", assessment: I18n.t('families.show.assessment'))) do |family|
        date_filter(eval(records).most_recents, "#{column}").map{ |a| a.created_at.to_date.to_formatted_s }.join(', ') if eval(records).any?
      end
    end
  end

  def date_of_completed_assessments
    records = 'family.assessments.defaults.completed'
    column = 'assessment_completed_date'

    if params[:data].presence == 'recent'
      @family_grid.column(column.to_sym, header: I18n.t("datagrid.columns.#{column}", assessment: I18n.t('families.show.assessment'))) do |family|
        eval(records).latest_record.try(:created_at).to_date.to_formatted_s if eval(records).any?
      end
    else
      @family_grid.column(column.to_sym, header: I18n.t("datagrid.columns.#{column}", assessment: I18n.t('families.show.assessment'))) do |family|
        assessments = map_assessment_and_score(family, '', nil)
        assessments.map{ |a| a.created_at.to_date.to_formatted_s }.join(', ') if assessments.any?
      end
    end
  end


  def custom_all_csi_assessments
    return unless params['type'] == 'basic_info' && @family_columns.visible_columns[:all_custom_csi_assessments_].present?
    domain_score_report('custom')
  end

  def domain_score_report(type)
    case type
    when 'default'
      records = 'family.assessments.defaults'
      column = 'all_csi_assessments'
    when 'custom'
      records = 'family.assessments.customs'
      column = 'all_custom_csi_assessments'
    end

    if params[:data].presence == 'recent'
      @family_grid.column(column.to_sym, header: t(".#{column}", assessment: I18n.t('families.show.assessment'))) do |family|
        recent_assessment = eval(records).latest_record
        "#{recent_assessment.created_at} => #{recent_assessment.assessment_domains_score}" if recent_assessment.present?
      end
    else
      @family_grid.column(column.to_sym, header: t(".#{column}", assessment: I18n.t('families.show.assessment'))) do |family|
        eval(records).map(&:basic_info).join("\x0D\x0A")
      end
    end
    @family_grid.column_names << column.to_sym if @family_grid.column_names.any?
  end

  def csi_domain_score_report
    Domain.family_custom_csi_domains.order_by_identity.each do |domain|
      identity = domain.identity
      if domain.custom_domain
        column = "custom_#{domain.convert_identity}".to_sym
        records = 'family.assessments.customs'
      else
        column = domain.convert_identity.to_sym
        records = 'family.assessments.defaults'
      end
      @family_grid.column(column, class: 'domain-scores', header: identity) do |family|
        assessments = map_assessment_and_score(family, identity, domain.id)
        assessment_domains = assessments.includes(:assessment_domains).map { |assessment| assessment.assessment_domains.joins(:domain).where(domains: { id: domain.id }) }.flatten.uniq
        assessment_domains.map{|assessment_domain| assessment_domain.try(:score) }.join(', ')
      end
    end
  end
end
