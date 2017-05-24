class VersionsController < AdminController
  def index
    @versions = Version.all
  end
end
