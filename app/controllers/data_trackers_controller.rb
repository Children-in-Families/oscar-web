class DataTrackersController < AdminController  
  def index
    if params[:item_type]
      @versions = PaperTrail::Version.where(item_type: params[:item_type])
    else
      @versions = PaperTrail::Version.all
    end
    @versions   = @versions.order(created_at: :desc).decorate
  end
end
