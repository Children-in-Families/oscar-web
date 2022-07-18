class ClientAdvancedSearchesController < AdminController
  include ClientAdvancedSearchesConcern
  include ClientGridOptions
  include CacheHelper

  before_action :assign_active_client_prams, only: :index
  before_action :format_search_params, only: [:index]
  before_action :get_quantitative_fields, :get_hotline_fields, :hotline_call_column, only: [:index]
  before_action :find_params_advanced_search, :get_custom_form, :get_program_streams, only: [:index]
  before_action :get_custom_form_fields, :program_stream_fields, :custom_form_fields, :client_builder_fields, only: [:index]
  before_action :basic_params, if: :has_params?, only: [:index]
  before_action :build_advanced_search, only: [:index]
  before_action :fetch_advanced_search_queries, only: [:index]
  before_action :choose_grid, only: [:index]

  def index
    @client_default_columns = Setting.cache_first.try(:client_default_columns)
    if params[:advanced_search_id]
      current_advanced_search = AdvancedSearch.find(params[:advanced_search_id])
      @visible_fields = current_advanced_search.field_visible
    end
    advanced_search
  end
end
