class ClientAdvancedSearchesController < AdminController
  include ClientGridOptions

  before_action :choose_grid
  before_action :find_params_advanced_search, :get_custom_fields, :get_program_streams, :client_builder_fields
  before_action :basic_params, if: :has_params?

  def index
    return unless has_params?
    basic_rules          = JSON.parse @basic_filter_params
    clients              = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability))
    @clients_by_user     = clients.filter

    columns_visibility
    respond_to do |f|
      f.html do
        @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability).page(params[:page]).per(20) }
      end
      f.xls do
        @client_grid.scope { |scope| scope.where(id: @clients_by_user.ids).accessible_by(current_ability) }
        domain_score_report
        send_data @client_grid.to_xls, filename: "client_report-#{Time.now}.xls"
      end
    end
  end

  private

  def client_builder_fields
    @builder_fields = get_client_basic_fields + get_custom_form_fields + get_enrollment_fields + get_tracking_fields + get_exit_program_fields
  end

  def get_custom_fields
    @custom_fields  = CustomField.client_forms.order_by_form_title
  end

  def get_program_streams
    @program_streams = ProgramStream.complete.ordered
  end

  def program_stream_params
    if  @advanced_search_params.present? && @advanced_search_params[:program_selected]
      eval @advanced_search_params[:program_selected]
    else
      []
    end
  end

  def custom_form_params
    if @advanced_search_params.present? && @advanced_search_params[:custom_form_selected].present?
      eval @advanced_search_params[:custom_form_selected]
    else
      []
    end
  end

  def get_client_basic_fields
    AdvancedSearches::ClientFields.new(user: current_user).render
  end

  def get_custom_form_fields
    @enrollment_fields = AdvancedSearches::CustomFields.new(custom_form_params).render
  end

  def get_enrollment_fields
    if @advanced_search_params.present? && @advanced_search_params[:enrollment_check].present?
      AdvancedSearches::EnrollmentFields.new(program_stream_params).render
    else
      []
    end
  end

  def get_tracking_fields
    if @advanced_search_params.present? && @advanced_search_params[:tracking_check].present?
      AdvancedSearches::TrackingFields.new(program_stream_params).render
    else
      []
    end
  end

  def get_exit_program_fields
    if @advanced_search_params.present? && @advanced_search_params[:exit_form_check].present?
      AdvancedSearches::ExitProgramFields.new(program_stream_params).render
    else
      []
    end
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
