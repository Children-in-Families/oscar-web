class AdvancedSearchSaveQueriesController < AdminController
  include AdvancedSearchHelper
  include ProgramStreamHelper
  before_action :find_advanced_search, only: [:edit, :update, :destroy]

  def new
    @advanced_search = AdvancedSearch.new
  end

  def create
    @advanced_search = AdvancedSearch.new(advanced_search_params)
    @advanced_search.user_id = current_user.id
    if @advanced_search.save
      redirect_to clients_path(save_search_params(@advanced_search.search_params).merge(advanced_search_id: @advanced_search.id)), notice: t('.successfully_created')
    else
      redirect_to clients_path, alert: t('.failed_create')
    end
  end

  def edit
  end

  def update
    if @advanced_search.update_attributes(advanced_search_params)
      redirect_to clients_path(save_search_params(@advanced_search.search_params).merge(advanced_search_id: @advanced_search.id)), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @advanced_search.destroy
    redirect_to clients_path, notice: t('.successfully_deleted')
  end

  private

  def advanced_search_params
    params.require(:advanced_search).permit(:name, :description, :queries, :enrollment_check, :tracking_check, :exit_form_check, :hotline_check, :field_visible, :quantitative_check, :custom_forms, :program_streams)
  end

  def find_advanced_search
    @advanced_search = current_user.advanced_searches.find(params[:id])
  end
end
