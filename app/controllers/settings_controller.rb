class SettingsController < AdminController

  def index
    @setting = Setting.first_or_initialize(assessment_frequency: 'month', min_assessment: 3, max_assessment: 6)
    country
  end

  def create
    @setting = Setting.new(setting_params)
    if @setting.save
      redirect_to settings_path, notice: t('.successfully_created')
    else
      render :index
    end
  end

  def update
    @setting = Setting.first
    if @setting.update_attributes(setting_params)
      redirect_to settings_path, notice: t('.successfully_updated')
    else
      render :index
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:disable_assessment, :assessment_frequency, :min_assessment, :max_assessment)
  end

  def country
    session[:country] ||= params[:country]
    unless flash[:notice].present?
      flash[:notice] = session[:country] == params[:country] ? nil : t(".switched_country_#{params[:country]}")
    end
    session[:country] = params[:country]
  end
end
