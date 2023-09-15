class SettingsController < AdminController
  rescue_from ActionController::RedirectBackError, with: :redirect_to_default
  include CommunityHelper

  before_action :find_setting, except: [:create]
  before_action :authorize_setting, except: [:create, :show]
  before_action :country_address_fields, only: [:edit, :update]

  def index
  end

  def screening_forms; end
  def care_plan; end

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
    render template: 'organizations/edit', locals: { current_setting: @setting }
  end

  def update
    @setting = @setting
    if params[:setting].has_key?(:org_form)
      if @setting.update_attributes(setting_params)
        redirect_to :back, notice: t('.successfully_updated')
      else
        render :edit
      end
    else
      respond_to do |f|
        f.html do
          if @setting.update_attributes(setting_params)
            redirect_to :back, notice: t('.successfully_updated')
          else
            flash[:alert] = @setting.errors.full_messages.join(", ")
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
    @client_default_columns = client_default_columns
    @family_default_columns = family_default_columns
    @community_default_columns = community_default_columns
    @partner_default_columns = partner_default_columns
  end

  def research_module
  end

  def custom_labels
  end

  def client_forms
  end

  def community
  end

  def family_case_management
  end

  def integration
    @current_organization = Organization.find_by(short_name: Apartment::Tenant.current)
    if request.put?
      @current_organization.integrated = params.dig(:setting, :integrated)
      @current_organization.last_integrated_date = Date.current if @current_organization.integrated?

      if @current_organization.save
        redirect_to integration_settings_path, notice: t('.successfully_updated')
      else
        render :integration
      end
    end
  end

  def header_count
    return unless request.put?

    if @setting.update_attributes(setting_params)
      redirect_to :back, notice: t('.successfully_updated')
    else
      render :header_count
    end
  end

  def custom_form
  end

  def test_client
  end

  def customize_case_note
  end

  def limit_tracking_form
    authorize @setting
  end

  def risk_assessment
    authorize @setting
    attribute = params[:setting]
    if attribute && @setting.update_attributes(setting_params)
      redirect_to :back, notice: t('successfully_updated', klass: t('settings.update.successfully_updated'))
    else
      flash[:alert] = @setting.errors.full_messages.join(", ") if @setting.errors.full_messages.any?
      render :risk_assessment
    end
  end

  private

  def redirect_to_default
    redirect_to settings_path
  end

  def country_address_fields
    @provinces = Province.cached_order_name
    @districts = Setting.cache_first.province.present? ? Setting.cache_first.province.districts.order(:name) : []
    @communes  = Setting.cache_first.district.present? ? Setting.cache_first.district.communes.order(:name_kh, :name_en) : []
  end

  def setting_params
    params.require(:setting).permit(:custom_assessment_frequency, :assessment_frequency, :max_custom_assessment,
                                    :max_assessment, :enable_custom_assessment, :enable_default_assessment, :age,
                                    :custom_age, :default_assessment, :custom_assessment, :max_case_note,
                                    :case_note_frequency, :org_name, :province_id, :district_id, :commune_id,
                                    :delete_incomplete_after_period_unit, :use_screening_assessment, :screening_assessment_form_id,
                                    :delete_incomplete_after_period_value, :two_weeks_assessment_reminder,
                                    :never_delete_incomplete_assessment, :show_prev_assessment, :use_previous_care_plan,
                                    :sharing_data, :custom_id1_latin, :custom_id1_local, :custom_id2_latin, :custom_id2_local,
                                    :enable_hotline, :enable_client_form, :assessment_score_order, :disable_required_fields,
                                    :hide_family_case_management_tool, :hide_community, :case_conference_limit, :case_conference_frequency,
                                    :internal_referral_limit, :internal_referral_frequency, :case_note_edit_limit, :case_note_edit_frequency,
                                    :disabled_future_completion_date, :cbdmat_one_off, :cbdmat_ongoing,
                                    :tracking_form_edit_limit, :tracking_form_edit_frequency, :disabled_add_service_received,
                                    :custom_field_limit, :custom_field_frequency, :test_client, :disabled_task_date_field,
                                    :required_case_note_note, :hide_case_note_note, :enabled_risk_assessment, :assessment_type_name,
                                    :level_of_risk_guidance, :organization_type, :enabled_header_count,
                                    client_default_columns: [], family_default_columns: [], community_default_columns: [],
                                    partner_default_columns: [], user_default_columns: [], selected_domain_ids: [],
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
    sub_columns = %w[carer_name_ carer_phone_ carer_email_ time_in_cps_ time_in_ngo_ rejected_note_ exit_reasons_ exit_circumstance_ other_info_of_exit_ exit_note_ what3words_ main_school_contact_ rated_for_id_poor_ name_of_referee
      family_ family_id_ case_note_date_ case_note_type_ date_of_assessments_ assessment_completed_date_ all_csi_assessments_ date_of_custom_assessments_ custom_assessment_ custom_completed_date_ custom_assessment_ created_date_ all_custom_csi_assessments_ manage_ changelog_ type_of_service_ indirect_beneficiaries_]
    sub_columns += Client::HOTLINE_FIELDS.map{ |field| "#{field}_" }
    sub_columns += Call::FIELDS.map{ |field| "#{field}_" }
    filter_columns = ClientGrid.new.filters.map(&:name).select{ |field_name| policy(Client).show?(field_name) }
    filter_columns_not_used = [:has_date_of_birth, :quantitative_data, :quantitative_types, :all_domains, :domain_1a, :domain_1b, :domain_2a, :domain_2b, :domain_3a,
      :domain_3b, :domain_4a, :domain_4b, :domain_5a, :domain_5b, :domain_6a, :domain_6b, :assessments_due_to, :no_case_note, :overdue_task, :overdue_forms, :province_id, :birth_province_id, :commune, :house_number, :village, :street_number, :district]
    columns_name = filter_columns - filter_columns_not_used
    columns = columns_name.map { |name| "#{name}_" }
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
    sub_columns = %w[member_count_ clients_ case_workers_ manage_ direct_beneficiaries_ changelog_]
    columns = FamilyGrid.new.filters.map{|f| "#{f.name.to_s}_" }
    unless current_setting.hide_family_case_management_tool?
      sub_columns += %w[case_note_date_ case_note_type_ assessment_completed_date_ date_of_custom_assessments_ all_custom_csi_assessments_]
      Domain.family_custom_csi_domains.order_by_identity.each do |domain|
        columns << "#{domain.convert_custom_identity}_"
      end
    end
    columns.push(sub_columns).flatten
  end

  def community_default_columns
    columns = []
    sub_columns = %w[manage_ changelog_]
    columns = community_grid_columns.map { |k, _| "#{k}_" }
    columns.push(sub_columns).flatten
  end

  def partner_default_columns
    columns = []
    sub_columns = %w[manage_ changelog_]
    columns = PartnerGrid.new.filters.map { |f| "#{f.name}_" }
    columns.push(sub_columns).flatten
  end

  def international_address_columns
    country = Setting.cache_first.try(:country_name) || params[:country]
    case country
    when 'thailand'
      %w[province_id_ birth_province_id_ district_ subdistrict_ postal_code_ plot_ road_]
    when 'lesotho'
      %w[suburb_ directions_ description_house_landmark_]
    when 'myanmar'
      %w[street_line1_ street_line2_ township_ state_]
    when 'uganda'
      %w[province_id_ birth_province_id_ district_ commune_ house_number_ village_ street_number_]
    else
      %w[province_id_ birth_province_id_ district_ commune_ house_number_ village_ street_number_]
    end
  end

  def authorize_setting
    authorize @setting
  end
end
