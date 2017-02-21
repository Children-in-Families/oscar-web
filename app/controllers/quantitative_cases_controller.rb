class QuantitativeCasesController < AdminController
  load_and_authorize_resource

 def version
    @quantitative_case = QuantitativeCase.find(params[:quantitative_case_id])
    @versions          = @quantitative_case.versions.reorder(created_at: :desc)
  end
end