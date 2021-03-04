module FamilyAdvancedSearchesConcern
  extend ActiveSupport::Concern
  include ClientsHelper

  def advanced_search
    basic_rules  = JSON.parse @basic_filter_params
    $param_rules = nil
    $param_rules = find_params_advanced_search
    @families    = AdvancedSearches::Families::FamilyAdvancedSearch.new(basic_rules, Family.accessible_by(current_ability)).filter
    custom_form_column
    program_stream_column
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
    @builder_fields = get_family_basic_fields + custom_form_fields + program_stream_fields
    @builder_fields = @builder_fields + @quantitative_fields if quantitative_check?
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

  def get_program_streams
    program_ids = Enrollment.pluck(:program_stream_id).uniq
    @program_streams = ProgramStream.where(id: program_ids).order(:name)
  end

  def program_stream_column
    @program_stream_columns = program_stream_fields.group_by{ |field| field[:optgroup] }
  end

  def program_stream_fields
    @program_stream_fields = get_enrollment_fields + get_tracking_fields + get_exit_program_fields
  end

  def get_enrollment_fields
    return [] if program_stream_values.empty? || !enrollment_check?
    AdvancedSearches::EnrollmentFields.new(program_stream_values).render
  end

  def get_tracking_fields
    return [] if program_stream_values.empty? || !tracking_check?
    AdvancedSearches::TrackingFields.new(program_stream_values).render
  end

  def get_exit_program_fields
    return [] if program_stream_values.empty? || !exit_program_check?
    AdvancedSearches::ExitProgramFields.new(program_stream_values).render
  end

  def program_stream_value?
    @advanced_search_params.present? && @advanced_search_params[:program_selected].present?
  end

  def program_stream_values
    program_stream_value? ? eval(@advanced_search_params[:program_selected]) : []
  end

  def enrollment_check?
    @advanced_search_params.present? && @advanced_search_params[:enrollment_check].present?
  end

  def tracking_check?
    @advanced_search_params.present? && @advanced_search_params[:tracking_check].present?
  end

  def exit_program_check?
    @advanced_search_params.present? && @advanced_search_params[:exit_form_check].present?
  end

  def get_quantitative_fields
    quantitative_fields = AdvancedSearches::QuantitativeCaseFields.new(current_user, 'family')
    @quantitative_fields = quantitative_fields.render
  end

  def quantitative_check?
    @advanced_search_params.present? && @advanced_search_params[:quantitative_check].present?
  end

  def program_stream_report
    @family_grid.column(:program_streams, header: I18n.t('datagrid.columns.families.program_streams')) do |family|
      family.enrollments.active.map{ |c| c.program_stream.try(:name) }.uniq.join(', ')
    end
  end

  def export_family_reports
    form_builder_report
    program_stream_report
  end
end
