class ClientAdvancedSearchesController < AdminController
  include ClientGridOptions

  before_action :choose_grid, :get_quantitative_fields
  before_action :find_params_advanced_search, :get_custom_form, :get_program_streams, :client_builder_fields
  before_action :basic_params, if: :has_params?

  def index
    return unless has_params?
    basic_rules          = JSON.parse @basic_filter_params
    clients              = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability))
    @clients_by_user     = clients.filter

    custom_form_column
    program_stream_column
    columns_visibility
    respond_to do |f|
      f.html do
        @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability).page(params[:page]).per(20) }
      end
      f.xls do
        @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability) }
        domain_score_report
        form_builder_report
        send_data @client_grid.to_xls, filename: "client_report-#{Time.now}.xls"
      end
    end
  end

  private

  def custom_form_column
    custom_form_columns    = @form_builder.select{ |c| c if c.include?('formbuilder_') }
    @custom_form_columns   = custom_form_columns.group_by{ |c| c.split('_').second }
  end

  def program_stream_column
    program_stream_columns  = @form_builder.select{ |c| c if c.exclude?('formbuilder_') }

    @program_stream_columns = program_stream_columns.group_by do |c|
      fields = c.split('_')
      fields.size < 4 ? [fields.second, fields.first] : [fields.second, fields.third, fields.first]
    end
  end

  def get_custom_form
    @custom_fields  = CustomField.client_forms.order_by_form_title
  end

  def client_builder_fields
    custom_program_fields = get_enrollment_fields + get_tracking_fields + get_exit_program_fields
    @builder_fields = get_client_basic_fields + get_custom_form_fields + custom_program_fields
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
    @enrollment_fields = AdvancedSearches::CustomFields.new(custom_form_values).render
  end

  def get_quantitative_fields
    @quantitative_fields = AdvancedSearches::QuantitativeCaseFields.render
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
