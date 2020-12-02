class Family::EnterNgosController < AdminController

  before_action :find_family

  def create
    @enter_ngo = @family.enter_ngos.new(enter_ngo_params)
    if @enter_ngo.save
      redirect_to @family, notice: t('.successfully_created')
    else
      redirect_to @family, alert: t('.failed_create')
    end
  end

  def update
    @enter_ngo = @family.enter_ngos.find(params[:id])
    authorize @enter_ngo
    if @enter_ngo.update_attributes(enter_ngo_params)
      redirect_to @family, notice: t('.successfully_updated')
    else
      redirect_to @family, alert: t('.failed_update')
    end
  end

  private

  def find_family
    @family = Family.find(params[:family_id])
  end

  def enter_ngo_params
    params.require(:enter_ngo).permit(:accepted_date, user_ids: [])
  end

end
