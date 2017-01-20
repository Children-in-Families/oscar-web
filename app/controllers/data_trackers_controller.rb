class DataTrackersController < AdminController
  load_and_authorize_resource

  def index
    if params[:item_type].present?
      @versions = PaperTrail::Version.where(item_type: params[:item_type])
    else
      @versions = PaperTrail::Version.all
    end
    @versions = @versions.order(created_at: :desc).page(params[:page]).per(params[:per_page])
  end
end
