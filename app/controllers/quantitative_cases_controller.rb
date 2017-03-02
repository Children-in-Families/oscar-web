class QuantitativeCasesController < AdminController
  load_and_authorize_resource

  def version
    page               = params[:per_page] || 20
    @quantitative_case = QuantitativeCase.find(params[:quantitative_case_id])
    @versions          = @quantitative_case.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end
end
