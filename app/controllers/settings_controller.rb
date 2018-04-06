class SettingsController < AdminController

  def index
    @setting = Setting.first_or_initialize(assessment_frequency: 'month', min_assessment: 3, max_assessment: 6)
    @client_default_columns = client_default_columns
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
    params.require(:setting).permit(:assessment_frequency, :min_assessment, :max_assessment, :min_case_note, :max_case_note, :case_note_frequency, client_default_columns: [])
  end

  def country
    session[:country] ||= params[:country]
    flash[:notice] = session[:country] == params[:country] ? nil : t(".switched_country_#{params[:country]}")
    session[:country] = params[:country]
  end

  def client_default_columns
    columns = []
    sub_columns = %w(history_of_harm history_of_high_risk_behaviours history_of_disability_and_or_illness reason_for_family_separation rejected_note exit_reasons
      exit_circumstance other_info_of_exit exit_note what3words main_school_contact rated_for_id_poor name_of_referee case_start_date carer_names  carer_address
      carer_phone_number support_amount support_note form_title family_preservation family partner case_note_date case_note_type date_of_assessments all_csi_assessments manage changelog)
    ClientGrid.new.filters.each do |f|
      next if f.name == :has_date_of_birth || f.name == :quantitative_data
      next if f.name == :quantitative_types || f.name == :all_domains
      next if f.name == :placement_date || f.name == :placement_case_type
      next if f.name == :domain_1a || f.name == :domain_1b
      next if f.name == :domain_2a || f.name == :domain_2b
      next if f.name == :domain_3a || f.name == :domain_3b
      next if f.name == :domain_4a || f.name == :domain_4b
      next if f.name == :domain_5a || f.name == :domain_5b
      next if f.name == :domain_6a || f.name == :domain_6b
      next if f.name == :assessments_due_to || f.name == :no_case_note || f.name == :overdue_task || f.name == :overdue_forms
      columns << f.name.to_s
    end
    Domain.order_by_identity.each do |domain|
      columns << domain.convert_identity
    end
    columns.push(sub_columns).flatten
  end
end
