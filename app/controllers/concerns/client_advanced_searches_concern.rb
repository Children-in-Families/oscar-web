module ClientAdvancedSearchesConcern
  include CallHelper

  def advanced_search
    if params[:advanced_search_id]
      advanced_search = AdvancedSearch.find(params[:advanced_search_id])
      basic_rules = advanced_search.queries
    else
      basic_rules  = JSON.parse @basic_filter_params || @wizard_basic_filter_params
    end
    $param_rules = find_params_advanced_search
    clients      = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability))

    @clients_by_user     = clients.filter
    columns_visibility
    custom_form_column
    program_stream_column

    respond_to do |f|
      f.html do
        @csi_statistics         = CsiStatistic.new(@client_grid.scope.where(id: @clients_by_user.ids).accessible_by(current_ability)).assessment_domain_score.to_json
        @enrollments_statistics = ActiveEnrollmentStatistic.new(@client_grid.scope.where(id: @clients_by_user.ids).accessible_by(current_ability)).statistic_data.to_json
        clients                 = @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability) }.assets
        @results                = clients.size
        @client_grid = @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability).page(params[:page]).per(20) }
      end
      f.xls do
        @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability) }
        export_client_reports
        send_data @client_grid.to_xls, filename: "client_report-#{Time.now}.xls"
      end
    end
  end

  def format_search_params
    advanced_search_params = params[:client_advanced_search]
    client_grid_params = params[:client_grid]
    return unless (advanced_search_params.is_a? String) || (client_grid_params.is_a? String)
    params[:client_advanced_search] = Rack::Utils.parse_nested_query(advanced_search_params)
    params[:client_grid] = Rack::Utils.parse_nested_query(client_grid_params)
  end

  def build_advanced_search
    @advanced_search = AdvancedSearch.new
  end

  def fetch_advanced_search_queries
    @my_advanced_searches    = current_user.advanced_searches.order(:name)
    @other_advanced_searches = AdvancedSearch.includes(:user).non_of(current_user).order(:name)
  end

  def custom_form_column
    @custom_form_columns = custom_form_fields.group_by{ |field| field[:optgroup] } if params.dig(:client_advanced_search, :action_report_builder) == '#builder'
    @wizard_custom_form_columns = custom_form_fields.group_by{ |field| field[:optgroup] } if params.dig(:client_advanced_search, :action_report_builder) == '#wizard-builder'
  end

  def program_stream_column
    @program_stream_columns = program_stream_fields.group_by{ |field| field[:optgroup] } if params.dig(:client_advanced_search, :action_report_builder) == '#builder'
    @wizard_program_stream_columns = program_stream_fields.group_by{ |field| field[:optgroup] } if params.dig(:client_advanced_search, :action_report_builder) == '#wizard-builder'
  end

  def get_custom_form
    form_ids = CustomFieldProperty.where(custom_formable_type: 'Client').pluck(:custom_field_id).uniq
    @custom_fields = CustomField.where(id: form_ids).order_by_form_title
  end

  def hotline_call_column
    client_hotlines = get_client_hotline_fields.group_by{ |field| field[:optgroup] }
    call_hotlines = get_hotline_fields.group_by{ |field| field[:optgroup] }
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
      @builder_fields = get_client_basic_fields + custom_form_fields + program_stream_fields
      @builder_fields = @builder_fields + @quantitative_fields if quantitative_check?
    end
  end

  def get_program_streams
    program_ids = ClientEnrollment.pluck(:program_stream_id).uniq
    @program_streams = ProgramStream.where(id: program_ids).order(:name)
  end

  def program_stream_values
    program_stream_value? ? eval(@advanced_search_params[:program_selected]) : []
  end

  def get_client_basic_fields
    AdvancedSearches::ClientFields.new(user: current_user, pundit_user: pundit_user).render
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
        ['not_a_phone_call', {true: 'Yes', false: 'No'}],
        ['requested_update', { true: 'Yes', false: 'No' }],
        *get_dropdown_list(['phone_call_id', 'call_type', 'start_datetime', 'protection_concern_id', 'necessity_id']),
      ]
    }

    hotline_fields = AdvancedSearches::AdvancedSearchFields.new('hotline', args).render

    @hotline_fields = get_client_hotline_fields + hotline_fields
  end

  def get_client_hotline_fields
    client_fields = I18n.t('datagrid.columns.clients')
    dropdown_list_options = [
      ['concern_address_type', [Client::ADDRESS_TYPES, Client::ADDRESS_TYPES.map{|type| I18n.t('default_client_fields.address_types')[type.downcase.to_sym] }].transpose.map{|k,v| { k.downcase => v } }],
      ['concern_province_id', Province.dropdown_list_option],
      ['concern_district_id', District.dropdown_list_option],
      ['concern_commune_id', Commune.dropdown_list_option],
      ['concern_village_id', Village.dropdown_list_option],
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

  def has_params?
    @advanced_search_params.present? && @advanced_search_params[:basic_rules].present?
  end

  def find_params_advanced_search
    if params[:advanced_search_id]
      advanced_search = AdvancedSearch.find(params[:advanced_search_id])
      @advanced_search_params = params[:client_advanced_search].merge("basic_rules" => advanced_search.queries)
    else
      @advanced_search_params = params[:client_advanced_search]
    end
  end

  def basic_params
    if params.dig(:client_advanced_search, :action_report_builder) == '#wizard-builder'
      @wizard_basic_filter_params  = @advanced_search_params[:basic_rules]
    else
      @basic_filter_params  = @advanced_search_params[:basic_rules]
    end
  end
end
