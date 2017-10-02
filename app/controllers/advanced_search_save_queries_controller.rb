class AdvancedSearchSaveQueriesController < AdminController
  def create
    @advanced_search = AdvancedSearch.new(advanced_search_params)    
    if @advanced_search.save
      redirect_to client_advanced_searches_path(search_params), notice: t('.successfully_created')
    else
      redirect_to client_advanced_searches_path
    end
  end

  private
  def advanced_search_params
    params.require(:advanced_search).permit(:name, :description, :queries, :enrollment_check, :tracking_check, :exit_form_check, :field_visible, :quantitative_check, :custom_forms, :program_streams)
  end

  def search_params
    { client_advanced_search: { custom_form_selected: @advanced_search.custom_forms,
                                program_selected: @advanced_search.program_streams,
                                enrollment_check: @advanced_search.enrollment_check,
                                tracking_check: @advanced_search.tracking_check,
                                exit_form_check: @advanced_search.exit_form_check,
                                basic_rules: @advanced_search.queries.to_json,
                                quantitative_check: @advanced_search.quantitative_check },
                                }.merge(@advanced_search.field_visible)
  end
end