class SettingsController < AdminController
  include CommunityHelper

  before_action :find_setting, only: [:index, :default_columns, :research_module, :custom_labels, :client_forms, :integration, :family_case_management, :community]
  before_action :country_address_fields, only: [:edit, :update]

  def index
    authorize @setting
  end

  def create
    @setting = Setting.new(setting_params)
    if @setting.save
      url = params[:default_columns].present? ? default_columns_settings_path : settings_path
      redirect_to url, notice: t('.successfully_created')
    else
      render :index
    end
  end

  def show
    redirect_to settings_path
  end

  def edit
    authorize @current_setting
    render template: 'organizations/edit', locals: { current_setting: @current_setting }
  end

  def update
    authorize @current_setting
    @setting = @current_setting
    if params[:setting].has_key?(:org_form)
      if @setting.update_attributes(setting_params)
        redirect_to root_path, notice: t('.successfully_updated')
      else
        render :edit
      end
    else
      respond_to do |f|
        f.html do
          if @setting.update_attributes(setting_params)
            if params[:default_columns].present? || params[:research_module].present? || params[:custom_labels].present? || params[:client_forms].present?
              redirect_to :back, notice: t('.successfully_updated')
            else
              redirect_to settings_path, notice: t('.successfully_updated')
            end
          else
            render :index
          end
        end
        f.json do
          @setting.update_attributes(setting_params)
          render json: { message: t('.successfully_updated') }, status: '200'
        end
      end
    end
  end

  def default_columns
    authorize @setting
    @client_default_columns = client_default_columns
    @family_default_columns = family_default_columns
    @community_default_columns = community_default_columns
    @partner_default_columns = partner_default_columns
  end

  def research_module
    authorize @current_setting
  end

  def custom_labels
    authorize @current_setting
  end

  def client_forms
    authorize @current_setting
  end

  def community
    authorize @current_setting
  end

  def family_case_management
    authorize @current_setting
  end

  def integration
    authorize @current_setting
    attribute = params[:setting]
    if attribute && current_organization.update_attributes(integrated: attribute[:integrated])
      redirect_to integration_settings_path, notice: t('.successfully_updated')
    else
      render :integration
    end
  end

  private

  def country_address_fields
    @provinces = Province.order(:name)
    @districts = Setting.first.province.present? ? Setting.first.province.districts.order(:name) : []
    @communes  = Setting.first.district.present? ? Setting.first.district.communes.order(:name_kh, :name_en) : []
  end

  def setting_params
    params.require(:setting).permit(:custom_assessment_frequency, :assessment_frequency, :max_custom_assessment,
                                    :max_assessment, :enable_custom_assessment, :enable_default_assessment, :age,
                                    :custom_age, :default_assessment, :custom_assessment, :max_case_note,
                                    :case_note_frequency, :org_name, :province_id, :district_id, :commune_id,
                                    :delete_incomplete_after_period_unit, :use_screening_assessment, :screening_assessment_form_id,
                                    :delete_incomplete_after_period_value, :two_weeks_assessment_reminder,
                                    :never_delete_incomplete_assessment, :show_prev_assessment,
                                    :sharing_data, :custom_id1_latin, :custom_id1_local, :custom_id2_latin, :custom_id2_local,
                                    :enable_hotline, :enable_client_form, :assessment_score_order, :disable_required_fields,
                                    :hide_family_case_management_tool, :hide_community,
                                    client_default_columns: [], family_default_columns: [], community_default_columns: [],
                                    partner_default_columns: [], user_default_columns: [],
                                    custom_assessment_settings_attributes: [:id, :custom_assessment_name, :max_custom_assessment, :custom_assessment_frequency, :custom_age, :enable_custom_assessment, :_destroy])
  end

  def custom_assessment_params
    params.require(:custom_assessment_setting).permit(:custom_assessment_name, :max_custom_assessment, :custom_assessment_frequency, :custom_age)
  end

  def find_setting
    @setting = Setting.first_or_initialize(case_note_frequency: 'day', max_case_note: 30)
  end

  def client_default_columns
    columns = []
    sub_columns = %w(time_in_cps_ time_in_ngo_ rejected_note_ exit_reasons_ exit_circumstance_ other_info_of_exit_ exit_note_ what3words_ main_school_contact_ rated_for_id_poor_ name_of_referee_
      family_ family_id_ case_note_date_ case_note_type_ date_of_assessments_ assessment_completed_date_ all_csi_assessments_ date_of_custom_assessments_ all_custom_csi_assessments_ manage_ changelog_ type_of_service_ indirect_beneficiaries_)
    sub_columns += Client::HOTLINE_FIELDS.map{ |field| "#{field}_" }
    sub_columns += Call::FIELDS.map{ |field| "#{field}_" }
    filter_columns = ClientGrid.new.filters.map(&:name).select{ |field_name| policy(Client).show?(field_name) }
    filter_columns_not_used = [:has_date_of_birth, :quantitative_data, :quantitative_types, :all_domains, :domain_1a, :domain_1b, :domain_2a, :domain_2b, :domain_3a,
      :domain_3b, :domain_4a, :domain_4b, :domain_5a, :domain_5b, :domain_6a, :domain_6b, :assessments_due_to, :no_case_note, :overdue_task, :overdue_forms, :province_id, :birth_province_id, :commune, :house_number, :village, :street_number, :district]
    columns_name = filter_columns - filter_columns_not_used
    columns = columns_name.map { |name| "#{name.to_s}_" }
    Domain.client_domians.order_by_identity.each do |domain|
      columns << "#{domain.convert_identity}_"
    end
    QuantitativeType.joins(:quantitative_cases).uniq.each do |quantitative_type|
      columns << "#{quantitative_type.name}_"
    end
    sub_columns = sub_columns.push(international_address_columns)
    columns.push(sub_columns).flatten
  end

  def family_default_columns
    columns = []
    sub_columns = %w(member_count_ clients_ case_workers_ case_note_date_ case_note_type_ assessment_completed_date_ date_of_custom_assessments_ all_custom_csi_assessments_ manage_ changelog_ direct_beneficiaries_)
    columns = FamilyGrid.new.filters.map{|f| "#{f.name.to_s}_" }
    Domain.family_custom_csi_domains.order_by_identity.each do |domain|
      columns << "#{domain.convert_custom_identity}_"
    end
    columns.push(sub_columns).flatten
  end

  def community_default_columns
    columns = []
    sub_columns = %w(manage_ changelog_)
    columns = community_grid_columns.map{ |k, _| "#{k}_" }
    columns.push(sub_columns).flatten
  end

  def partner_default_columns
    columns = []
    sub_columns = %w(manage_ changelog_)
    columns = PartnerGrid.new.filters.map { |f| "#{f.name}_" }
    columns.push(sub_columns).flatten
  end

  def international_address_columns
    country = Setting.first.try(:country_name) || params[:country]
    case country
    when 'thailand'
      %w(province_id_ birth_province_id_ district_ subdistrict_ postal_code_ plot_ road_)
    when 'lesotho'
      %w(suburb_ directions_ description_house_landmark_)
    when 'myanmar'
      %w(street_line1_ street_line2_ township_ state_)
    when 'uganda'
      %w(province_id_ birth_province_id_ district_ commune_ house_number_ village_ street_number_)
    else
      %w(province_id_ birth_province_id_ district_ commune_ house_number_ village_ street_number_)
    end
  end
end
