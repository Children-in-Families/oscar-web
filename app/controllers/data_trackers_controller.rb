class DataTrackersController < AdminController
  load_and_authorize_resource

  def index
  	page = params[:per_page] || 20
    if params[:item_type].present?
      @versions = PaperTrail::Version.where(item_type: params[:item_type])
    else
    	@versions = PaperTrail::Version.where.not(item_type:exclude_item_type)
    end
    @versions = @versions.order(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def exclude_item_type
  	%w(AssessmentDomain CaseNoteDomainGroup CaseNote AgencyClient ClientQuantitativeCase)
  end
end
