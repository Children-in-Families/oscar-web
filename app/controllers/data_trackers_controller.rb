class DataTrackersController < AdminController  
  def index
    @versions = PaperTrail::Version.where.not(item_type: ['AgenciesClient']).order(created_at: :desc).decorate
  end
end
