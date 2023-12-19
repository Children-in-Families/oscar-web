module ClientAdvancedSearchesConcern
  include CallHelper

  def advanced_search
    if params[:advanced_search_id]
      advanced_search = AdvancedSearch.find(params[:advanced_search_id])
      basic_rules = advanced_search.queries
    else
      basic_rules = JSON.parse @basic_filter_params || @wizard_basic_filter_params || '{}'
    end

    $param_rules = find_params_advanced_search
    _clients, query = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability)).filter

    @results = @clients_by_user = @client_grid.scope { |scope| scope.where(query).accessible_by(current_ability) }.assets
    cache_client_ids

    client_columns_visibility
    custom_form_column
    program_stream_column

    respond_to do |f|
      f.html do
        begin
          @client_grid = @client_grid.scope { |scope| scope.where(query).accessible_by(current_ability).page(params[:page]).per(20) }
        rescue NoMethodError
          redirect_to welcome_clients_path
        end
      end
      f.xls do
        @client_grid.scope { |scope| scope.where(query).accessible_by(current_ability) }
        @client_grid.params = params.to_unsafe_h.dup.deep_symbolize_keys

        export_client_reports
        send_data @client_grid.to_xls, filename: "client_report-#{Time.now}.xls"
      end
    end
  end

  def format_search_params
    advanced_search_params = params[:client_advanced_search]
    client_grid_params = params[:client_grid]
    params[:client_advanced_search] = Rack::Utils.parse_nested_query(advanced_search_params) if advanced_search_params.is_a? String
    params[:client_grid] = Rack::Utils.parse_nested_query(client_grid_params) if client_grid_params.is_a? String
    params
  end

  def build_advanced_search
    @advanced_search = AdvancedSearch.new
  end

  def fetch_advanced_search_queries
    @my_advanced_searches = current_user.cache_advance_saved_search
    @other_advanced_searches = Rails.cache.fetch(user_cache_id << 'other_advanced_search_queries') do
      AdvancedSearch.for_client.includes(:user).non_of(current_user).to_a
    end
  end

  def custom_form_column
    @custom_form_columns = custom_form_fields.group_by { |field| field[:optgroup] } if params.dig(:client_advanced_search, :action_report_builder) == '#builder'
    @wizard_custom_form_columns = custom_form_fields.group_by { |field| field[:optgroup] } if params.dig(:client_advanced_search, :action_report_builder) == '#wizard-builder'
  end

  def program_stream_column
    @program_stream_columns = program_stream_fields.group_by { |field| field[:optgroup] } if params.dig(:client_advanced_search, :action_report_builder) == '#builder'
    @wizard_program_stream_columns = program_stream_fields.group_by { |field| field[:optgroup] } if params.dig(:client_advanced_search, :action_report_builder) == '#wizard-builder'
  end

  def get_custom_form
    form_ids = CustomFieldProperty.cached_custom_formable_type
    @custom_fields = CustomField.cached_order_by_form_title(form_ids)
  end

  def hotline_call_column
    client_hotlines = get_client_hotline_fields.group_by { |field| field[:optgroup] }
    call_hotlines = get_hotline_fields.group_by { |field| field[:optgroup] }
    @hotline_call_columns = client_hotlines.merge(call_hotlines)
  end

  def program_stream_fields
    if params.dig(:client_advanced_search, :action_report_builder) == '#wizard-builder'
      @wizard_program_stream_fields = get_enrollment_fields + get_tracking_fields + get_exit_program_fields
    else
      @program_stream_fields = get_enrollment_fields + get_tracking_fields + get_exit_program_fields
    end
  end

  def client_builder_fields
    @builder_fields = get_client_basic_fields
    if params.dig(:client_advanced_search, :action_report_builder) == '#wizard-builder'
      @builder_fields = @builder_fields + program_stream_fields if @advanced_search_params[:wizard_program_stream_check].present?
      @builder_fields = @builder_fields + custom_form_fields if @advanced_search_params[:wizard_custom_form_check].present?
      @builder_fields = @builder_fields + @quantitative_fields if @advanced_search_params[:wizard_quantitative_check].present?
    else
      @builder_fields = @builder_fields + custom_form_fields + program_stream_fields + get_common_fields + render_risk_assessment_fields
      @builder_fields = @builder_fields + @quantitative_fields if quantitative_check?
    end
  end

  def get_program_streams
    @program_streams = ProgramStream.cache_program_steam_by_enrollment
  end

  def program_stream_values
    program_stream_value? ? eval(@advanced_search_params[:program_selected]) : []
  end

  def get_client_basic_fields
    AdvancedSearches::ClientFields.new(user: current_user, pundit_user: pundit_user).render
  end

  def get_common_fields
    fields = program_stream_values.empty? ? [] : AdvancedSearches::CommonFields.new(program_stream_values).render
    fields += assessment_values.empty? ? [] : AdvancedSearches::CommonFields.new(program_stream_values, true).render

    fields.uniq
  end

  def get_hotline_fields
    args = {
      translation: get_basic_field_translations, number_field: [],
      text_field: ['information_provided', 'brief_note_summary', 'other_more_information'],
      date_picker_field: ['date_of_call'],
      dropdown_list_option: [
        ['answered_call', { true: 'Yes', false: 'No' }],
        ['childsafe_agent', { true: 'Yes', false: 'No' }],
        ['called_before', { true: 'Yes', false: 'No' }],
        ['not_a_phone_call', { true: 'Yes', false: 'No' }],
        ['requested_update', { true: 'Yes', false: 'No' }],
        *get_dropdown_list(['phone_call_id', 'call_type', 'start_datetime', 'protection_concern_id', 'necessity_id'])
      ]
    }
    hotline_fields = AdvancedSearches::AdvancedSearchFields.new('hotline', args).render
    @hotline_fields = get_client_hotline_fields + hotline_fields
  end

  def get_client_hotline_fields
    client_fields = I18n.t('datagrid.columns.clients')
    dropdown_list_options = [
      ['concern_address_type', [Client::ADDRESS_TYPES, Client::ADDRESS_TYPES.map { |type| I18n.t('default_client_fields.address_types')[type.downcase.to_sym] }].transpose.map { |k, v| { k.downcase => v } }],
      ['concern_province_id', Province.cached_dropdown_list_option],
      ['concern_district_id', District.cached_dropdown_list_option],
      ['concern_commune_id', Commune.cached_dropdown_list_option],
      ['concern_village_id', Village.cached_dropdown_list_option],
      ['concern_is_outside', { true: 'Yes', false: 'No' }],
      ['concern_same_as_client', { true: 'Yes', false: 'No' }]
    ]
    args = {
      translation: client_fields.merge({ concern_basic_fields: I18n.t('advanced_search.fields.concern_basic_fields') }), number_field: [],
      text_field: hotline_text_type_list, date_picker_field: [],
      dropdown_list_option: dropdown_list_options
    }
    @client_hotline_fields = AdvancedSearches::AdvancedSearchFields.new('concern_basic_fields', args).render
  end

  def hotline_text_type_list
    %w(nickname concern_address concern_email concern_email_owner concern_house concern_location concern_outside_address concern_phone concern_phone_owner concern_street location_description phone_counselling_summary)
  end

  def custom_form_values
    custom_form_value? ? eval(@advanced_search_params[:custom_form_selected]) : []
  end

  def custom_form_fields
    if params.dig(:client_advanced_search, :action_report_builder) == '#wizard-builder'
      @wizard_custom_form_fields = get_custom_form_fields + get_has_this_form_fields
    else
      @custom_form_fields = get_custom_form_fields + get_has_this_form_fields
    end
  end

  def get_custom_form_fields
    @custom_forms = custom_form_values.empty? ? [] : AdvancedSearches::CustomFields.new(custom_form_values).render
  end

  def get_has_this_form_fields
    @has_this_form_fields = custom_form_values.empty? ? [] : AdvancedSearches::HasThisFormFields.new(custom_form_values).render
  end

  def get_quantitative_fields
    quantitative_fields = AdvancedSearches::QuantitativeCaseFields.new(current_user)
    @quantitative_fields = quantitative_fields.render
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

  def render_risk_assessment_fields
    @render_risk_assessment_fields ||= AdvancedSearches::RiskAssessmentFields.render
  end

  def program_stream_value?
    @advanced_search_params.present? && @advanced_search_params[:program_selected].present?
  end

  def custom_form_value?
    @advanced_search_params.present? && @advanced_search_params[:custom_form_selected].present?
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

  def quantitative_check?
    @advanced_search_params.present? && @advanced_search_params[:quantitative_check].present?
  end

  def assessment_value?
    @advanced_search_params.present? && @advanced_search_params[:assessment_selected].present?
  end

  def assessment_values
    assessment_value? ? eval(@advanced_search_params[:assessment_selected]) : []
  end

  def has_params?
    @advanced_search_params.present? && @advanced_search_params[:basic_rules].present?
  end

  def find_params_advanced_search
    if params[:advanced_search_id]
      advanced_search = AdvancedSearch.cached_advanced_search(params[:advanced_search_id])
      @advanced_search_params = params[:client_advanced_search].merge('basic_rules' => advanced_search.queries)
    else
      @advanced_search_params = params[:client_advanced_search]
    end
  end

  def basic_params
    if params.dig(:client_advanced_search, :action_report_builder) == '#wizard-builder'
      @wizard_basic_filter_params = @advanced_search_params[:basic_rules]
    else
      @basic_filter_params = @advanced_search_params[:basic_rules]
    end
  end

  def legal_doc_params
    [
      :ngo_partner,
      :remove_ngo_partner_files,
      :mosavy,
      :remove_referral_doc_files,
      :dosavy,
      :remove_dosavy_files,
      :msdhs,
      :remove_msdhs_files,
      :complain,
      :remove_complain_files,
      :warrant,
      :remove_warrant_files,
      :verdict,
      :remove_verdict_files,
      :referral_doc_option,
      :short_form_of_ocdm,
      :screening_interview_form,
      :screening_interview_form_option,
      :remove_screening_interview_form_files,
      :short_form_of_ocdm_option,
      :remove_short_form_of_ocdm_files,
      :short_form_of_mosavy_dosavy,
      :short_form_of_mosavy_dosavy_option,
      :remove_short_form_of_mosavy_dosavy_files,
      :detail_form_of_mosavy_dosavy,
      :detail_form_of_mosavy_dosavy_option,
      :remove_detail_form_of_mosavy_dosavy_files,
      :short_form_of_judicial_police,
      :short_form_of_judicial_police_option,
      :remove_short_form_of_judicial_police_files,
      :detail_form_of_judicial_police,
      :detail_form_of_judicial_police_option,
      :letter_from_immigration_police,
      :remove_letter_from_immigration_police_files,
      :remove_detail_form_of_judicial_police_files,
      ngo_partner_files: [],
      dosavy_files: [],
      msdhs_files: [],
      complain_files: [],
      warrant_files: [],
      verdict_files: [],
      national_id_files: [],
      referral_doc_files: [],
      short_form_of_ocdm_files: [],
      screening_interview_form_files: [],
      short_form_of_mosavy_dosavy_files: [],
      detail_form_of_mosavy_dosavy_files: [],
      short_form_of_judicial_police_files: [],
      detail_form_of_judicial_police_files: [],
      letter_from_immigration_police_files: []
    ]
  end

  def cache_client_ids
    @cache_key = "cache_client_ids_#{current_user.id}_#{Time.current.to_i}"
    Rails.cache.write(@cache_key, @results.ids.join(','), expires_in: 10.minutes)
  end
end
