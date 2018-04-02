class SettingsController < AdminController

  def index
    @setting = Setting.first_or_initialize(assessment_frequency: 'month', min_assessment: 3, max_assessment: 6)
    country
  end

  def create
    @setting = Setting.new(setting_params)
    if @setting.save
      redirect_to settings_path, notice: 'Successfully save setting'
    else
      render :index, notice: 'Failed to save setting'
    end
  end

  def update
    @setting = Setting.first
    if @setting.update_attributes(setting_params)
      redirect_to settings_path, notice: 'Successfully save setting'
    else
      render :index, notice: 'Failed to save setting'
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:assessment_frequency, :min_assessment, :max_assessment)
  end

  def country
    session[:country] ||= params[:country]
    flash[:notice] = session[:country] == params[:country] ? nil : t(".switched_country_#{params[:country]}")
    session[:country] = params[:country]
  end
end
