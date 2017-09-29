class AdvancedSearchSaveQueriesController < AdminController
  def create
    @advanced_search = AdvancedSearch.new(advanced_search_params)    
    if @advanced_search.save
      redirect_to client_advanced_searches_path(@advanced_search.search_params), notice: t('.successfully_created')
    else
      redirect_to client_advanced_searches_path
    end
  end

  private
  def advanced_search_params
    params.require(:advanced_search).permit(:name, :description, :queries, :enrollment_check, :tracking_check, :exit_form_check, :field_visible, :quantitative_check, :custom_forms, :program_streams)
  end
end