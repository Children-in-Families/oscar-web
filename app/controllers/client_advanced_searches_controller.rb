class ClientAdvancedSearchesController < AdminController
  include ClientGridOptions

  before_action :choose_grid
  before_action :find_params_advanced_search, :get_custom_fields, :get_program_streams
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

  def get_custom_fields
    @custom_fields  = CustomField.client_forms.order_by_form_title
  end

  def get_program_streams
    @program_streams = ProgramStream.completed.ordered
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
