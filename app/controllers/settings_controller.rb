class SettingsController < AdminController
  def index
    @setting = Setting.first_or_initialize(assessment_frequency: 'month', min_assessment: 3, max_assessment: 6, case_note_frequency: 'day', max_case_note: 30)
  end

  def create
    @setting = Setting.new(setting_params)
    if @setting.save
      url = params[:id] == 'default_columns' ? default_columns_settings_path : settings_path
      redirect_to url, notice: t('.successfully_created')
    else
      render :index
    end
  end

  def show
    redirect_to settings_path
  end

  def update
    @setting = Setting.first
    if @setting.update_attributes(setting_params)
      url = params[:id] == 'default_columns' ? default_columns_settings_path : settings_path
      redirect_to url, notice: t('.successfully_updated')
    else
      render :index
    end
  end

  def country
    session[:country] ||= params[:country]
    unless flash[:notice].present?
      flash[:notice] = session[:country] == params[:country] ? nil : t(".switched_country_#{params[:country]}")
    end
    session[:country] = params[:country]
  end

  def default_columns
    @setting = Setting.first_or_initialize
    @client_default_columns = client_default_columns
    @family_default_columns = family_default_columns
    @partner_default_columns = partner_default_columns
  end

  private

  def setting_params
    params.require(:setting).permit(:disable_assessment, :assessment_frequency, :min_assessment, :max_assessment, :max_case_note, :case_note_frequency, client_default_columns: [], family_default_columns: [], partner_default_columns: [], user_default_columns: [])
  end

  def client_default_columns
    columns = []
    sub_columns = %w(history_of_harm_ history_of_high_risk_behaviours_ history_of_disability_and_or_illness_ reason_for_family_separation_ rejected_note_ exit_reasons_
      exit_circumstance_ other_info_of_exit_ exit_note_ what3words_ main_school_contact_ rated_for_id_poor_ name_of_referee_ case_start_date_ carer_names_  carer_address_
      carer_phone_number_ support_amount_ support_note_ form_title_ family_preservation_ family_ partner_ case_note_date_ case_note_type_ date_of_assessments_ all_csi_assessments_ manage_ changelog_)
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
      columns << "#{f.name.to_s}_"
    end
    Domain.order_by_identity.each do |domain|
      columns << "#{domain.convert_identity}_"
    end
    columns.push(sub_columns).flatten
  end

  def family_default_columns
    columns = []
    sub_columns = %w(member_count_ clients_ case_workers_ manage_ changelog_)
    columns = FamilyGrid.new.filters.map{|f| "#{f.name.to_s}_" }
    columns.push(sub_columns).flatten
  end

  def partner_default_columns
    columns = []
    sub_columns = %w(manage_ changelog_)
    columns = PartnerGrid.new.filters.map{|f| "#{f.name.to_s}_" }
    columns.push(sub_columns).flatten
  end
end
