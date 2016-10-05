class DataTrackersController < AdminController  
  def index
    @versions = PaperTrail::Version.all
  end
end
