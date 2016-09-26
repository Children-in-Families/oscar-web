class ChangelogsController < AdminController
  load_and_authorize_resource

  before_action :find_changelog, only: [:show, :edit, :update, :destroy]
  before_action :find_user

  def index
    @changelogs = Changelog.all
  end

  def new
    @changelog = @user.changelogs.new
    @changelog.changelog_types.new
  end

  def create
    @changelog = @user.changelogs.new(changelog_params)
    if @changelog.save
      redirect_to changelogs_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @changelog.update_attributes(changelog_params)
      redirect_to changelogs_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @changelog.destroy
    redirect_to changelogs_url, notice: t('.successfully_deleted')
  end

  private

  def changelog_params
    params.require(:changelog).permit(:version, changelog_types_attributes: [:id, :change_type, :description, :_destroy])
  end

  def find_changelog
    @changelog = Changelog.find(params[:id])
  end

  def find_user
    @user = current_user
  end
end
