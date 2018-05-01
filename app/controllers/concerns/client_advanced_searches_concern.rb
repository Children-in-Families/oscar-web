module ClientAdvancedSearchesConcern
  def advanced_search
    basic_rules          = JSON.parse @basic_filter_params
    # overdue_assessment   = @advanced_search_params[:overdue_assessment]
    # clients              = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability), overdue_assessment)
    clients              = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability))
    @clients_by_user     = clients.filter

    columns_visibility

    custom_form_column
    program_stream_column
    respond_to do |f|
      f.html do
        @csi_statistics         = CsiStatistic.new(@client_grid.scope.where(id: @clients_by_user.ids).accessible_by(current_ability)).assessment_domain_score.to_json
        @enrollments_statistics = ActiveEnrollmentStatistic.new(@client_grid.scope.where(id: @clients_by_user.ids).accessible_by(current_ability)).statistic_data.to_json
        @results                = @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability) }.assets.size
        @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability).page(params[:page]).per(20) }
      end
      f.xls do
        @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability) }
        export_client_reports
        send_data @client_grid.to_xls, filename: "client_report-#{Time.now}.xls"
      end
    end
  end

  def build_advanced_search
    @advanced_search = AdvancedSearch.new
  end

  def fetch_advanced_search_queries
    @my_advanced_searches    = current_user.advanced_searches.order(:name)
    @other_advanced_searches = AdvancedSearch.non_of(current_user).order(:name)
  end

  def custom_form_column
    @custom_form_columns = get_custom_form_fields.group_by{ |field| field[:optgroup] }
  end

  def program_stream_column
    @program_stream_columns = program_stream_fields.group_by{ |field| field[:optgroup] }
  end

  def get_custom_form
    @custom_fields  = CustomField.joins(:custom_field_properties).client_forms.order_by_form_title.uniq
  end

  def program_stream_fields
    @program_stream_fields = get_enrollment_fields + get_tracking_fields + get_exit_program_fields
  end

  def client_builder_fields
    @builder_fields = get_client_basic_fields + get_custom_form_fields + program_stream_fields
    @builder_fields = @builder_fields + @quantitative_fields if quantitative_check?
  end

  def get_program_streams
    @program_streams = ProgramStream.complete.joins(:client_enrollments).order(:name).uniq
  end

  def program_stream_values
    program_stream_value? ? eval(@advanced_search_params[:program_selected]) : []
  end

  def get_client_basic_fields
    AdvancedSearches::ClientFields.new(user: current_user).render
  end

  def custom_form_values
    custom_form_value? ? eval(@advanced_search_params[:custom_form_selected]) : []
  end

  def get_custom_form_fields
    @custom_form_fields = AdvancedSearches::CustomFields.new(custom_form_values).render
  end

  def get_quantitative_fields
    quantitative_fields = AdvancedSearches::QuantitativeCaseFields.new(current_user)
    @quantitative_fields = quantitative_fields.render
  end

  def get_enrollment_fields
    @enrollment_fields = AdvancedSearches::EnrollmentFields.new(program_stream_values).render
    enrollment_check? ? @enrollment_fields : []
  end

  def get_tracking_fields
    @tracking_fields = AdvancedSearches::TrackingFields.new(program_stream_values).render
    tracking_check? ? @tracking_fields : []
  end

  def get_exit_program_fields
    @exit_program_fields = AdvancedSearches::ExitProgramFields.new(program_stream_values).render
    exit_program_check? ? @exit_program_fields : []
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
    @advanced_search_params = params[:client_advanced_search]
  end

  def basic_params
    @basic_filter_params  = @advanced_search_params[:basic_rules]
  end
end
