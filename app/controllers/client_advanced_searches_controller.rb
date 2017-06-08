class ClientAdvancedSearchesController < AdminController
  include ClientGridOptions

  before_action :choose_grid
  before_action :find_params_advanced_search
  before_action :basic_params, :custom_field_params, :date_range_params, if: :has_params?

  def index
    authorize :client_advanced_search
    return unless has_params?
    basic_rules          = eval(@basic_filter_params)
    custom_form_rules    = eval(@custom_form_filter_params).merge(selected_custom_form: params[:client_advanced_search][:selected_custom_form])
    date_range           = @date_range_filter_params

    if date_range.present?
      @client_histories = ClientHistory.all
      clients           = AdvancedSearches::ClientHistoryAdvancedSearch.new(basic_rules, custom_form_rules, @client_histories, date_range)
    else
      clients           = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, custom_form_rules, Client.accessible_by(current_ability))
    end
    @clients_by_user    = clients.filter

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

  def has_params?
    advanced_search_param = params[:client_advanced_search]
    advanced_search_param.present? && (advanced_search_param[:basic_rules].present? || advanced_search_param[:custom_form_rules].present?)
  end

  def find_params_advanced_search
    @advanced_search_params = params[:client_advanced_search]
  end

  def basic_params
    @basic_filter_params  = @advanced_search_params[:basic_rules]
  end

  def custom_field_params
    @custom_form_filter_params  = @advanced_search_params[:custom_form_rules]
  end

  def date_range_params
    @date_range_filter_params = [@advanced_search_params[:start_date], @advanced_search_params[:end_date]]
  end
end
