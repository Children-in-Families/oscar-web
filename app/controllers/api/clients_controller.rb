module Api
  class ClientsController < Api::ApplicationController
    include ClientAdvancedSearchesConcern
    include ClientsConcern

    def search_client
      clients = Client.all.where('given_name ILIKE ? OR family_name ILIKE ? OR local_given_name ILIKE ? OR local_family_name ILIKE ? OR slug ILIKE ?', "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%").select(:id, :slug, :given_name, :family_name, :local_given_name, :local_family_name)
      render json: clients, serializer: false
    end

    def compare
      render json: { similar_fields: Client.find_shared_client(params)[:similar_fields] }
    end

    def render_client_statistics
      render json: client_statistics
    end

    def find_client_case_worker
      client = Client.find(params[:id])
      user_ids = client.users.non_strategic_overviewers.where.not(id: params[:user_id]).ids
      render json: { user_ids: user_ids }
    end

    def assessments
      $param_rules = params

      client_ids = if searched_client_ids.present?
                     searched_client_ids.split(',')
                   else
                     basic_rules = JSON.parse(params[:basic_rules] || '{}')
                     clients, _query = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability)).filter
                     clients.ids
                   end

      assessments = Assessment.joins(:client).where(default: params[:default], client_id: client_ids)
      assessments = assessments.joins(:custom_assessment_setting).where(custom_assessment_settings: { id: params[:assessment_id] }) if params[:assessment_id].present?

      @assessments_count = assessments.count

      render json: { recordsTotal: @assessments_count, recordsFiltered: @assessments_count, data: data }
    end

    def create
      client_saved = false
      client = Client.new(client_params)
      check_is_referral_saved?(params[:referral_id]) if params[:referral_id]
      assign_global_id_from_referral(client, params)
      client.transaction do
        if params.dig(:referee, :id).present?
          referee = Referee.find(params.dig(:referee, :id))
          referee.update(referee_params)
        else
          if referee_params[:anonymous] == 'true'
            referee = Referee.new(referee_params)
          else
            referee = Referee.find_or_initialize_by(referee_params)
          end
          referee.save
        end

        carer = Carer.find_or_initialize_by(carer_params)
        carer.save

        client.referee_id = referee.id
        client.carer_id = carer.id
        client_saved = client.save
      end
      if client_saved
        qtt_free_text_cases = params[:client_quantitative_free_text_cases]

        if qtt_free_text_cases.present?
          qtt_free_text_cases.select(&:present?).each do |client_qt_free_text_attr|
            client_qt_free_text = client.client_quantitative_free_text_cases.find_or_initialize_by(quantitative_type_id: client_qt_free_text_attr[:quantitative_type_id])
            client_qt_free_text.content = client_qt_free_text_attr[:content]
            client_qt_free_text.save
          end
        end

        if risk_assessment_params
          risk_assessment = RiskAssessmentReducer.new(client, risk_assessment_params, 'create')
          risk_assessment.store
        end

        custom_data = CustomData.first
        client.create_client_custom_data(custom_data_params.merge(custom_data_id: custom_data.id)) if custom_data && params.key?(:custom_data)

        render json: { slug: client.slug, id: client.id }, status: :ok
      else
        render json: client.errors, status: :unprocessable_entity
      end
    end

    def update
      client = Client.find(params[:client][:id] || params[:id])
      if params[:client][:id]
        referee = Referee.find_or_create_by(id: client.referee_id)
        referee.update_attributes(referee_params)
        client.referee_id = referee.id
        carer = Carer.find_or_create_by(id: client.carer_id)
        carer.update_attributes(carer_params)
        client.carer_id = carer.id
        new_params = client.current_family_id ? client_params : client_params.except(:family_ids)
      end

      if client.update_attributes(client_params.except(:referee_id, :carer_id))
        qtt_free_text_cases = params[:client_quantitative_free_text_cases]

        if qtt_free_text_cases.present?
          qtt_free_text_cases.select(&:present?).each do |client_qt_free_text_attr|
            client_qt_free_text = client.client_quantitative_free_text_cases.find_or_initialize_by(quantitative_type_id: client_qt_free_text_attr[:quantitative_type_id])
            client_qt_free_text.content = client_qt_free_text_attr[:content]
            client_qt_free_text.save
          end
        end

        if risk_assessment_params
          risk_assessment = RiskAssessmentReducer.new(client, risk_assessment_params, 'update')
          risk_assessment.store
        end

        custom_data = CustomData.first
        if custom_data && params.key?(:custom_data)
          if client.client_custom_data&.persisted?
            client.client_custom_data.update_attributes(custom_data_params)
          else
            client.create_client_custom_data(custom_data_params.merge(custom_data_id: custom_data.id))
          end
        end

        if params[:client][:assessment_id]
          Assessment.find(params[:client][:assessment_id])
        else
          render json: { slug: client.slug }, status: :ok
        end
      else
        render json: client.errors, status: :unprocessable_entity
      end
    end

    def render_client_by_gender
      clients = Client.accessible_by(current_ability).active_status
      client_data = {
        client_count: clients.count,
        adult_females: adule_client_gender_count(clients, :female),
        adult_males: adule_client_gender_count(clients, :male),
        girls: under_18_client_gender_count(clients, :female),
        boys: under_18_client_gender_count(clients, :male),
        others: other_client_gender_count(clients)
      }
      render json: client_data
    end

    def render_active_client_by_donor
      data = Donor.includes(:clients).references(:clients).where(clients: { id: Client.accessible_by(current_ability).active_status.ids }).group('donors.name').count('clients.id')
      donors = Donor.pluck(:name, :id)
      donor_data = data.map do |donor_name, client_count|
        url = { 'condition' => 'AND', 'rules' => [
          { 'id' => 'status', 'field' => 'Status', 'type' => 'string', 'input' => 'select', 'operator' => 'equal', 'value' => 'Active', 'data' => { 'values' => [{ 'Accepted' => 'Accepted' }, { 'Active' => 'Active' }, { 'Exited' => 'Exited' }, { 'Referred' => 'Referred' }], 'isAssociation' => false } },
          { 'id' => 'donor_name', 'field' => 'Donor', 'type' => 'string', 'input' => 'select', 'operator' => 'equal', 'value' => donors.to_h[donor_name], 'data' => { 'values' => donors.reverse.to_h, 'isAssociation' => true }, 'valid' => true }
        ] }

        {
          name: donor_name,
          y: client_count,
          url: clients_path(
            'client_advanced_search': {
              action_report_builder: '#builder',
              basic_rules: url.to_json
            },
            commit: 'commit'
          )
        }
      end
      render json: { data: donor_data }
    end

    private

    def client_params
      if params[:mosavy_officials].present?
        params[:client][:mo_savy_officials_attributes] = {}

        params[:mosavy_officials].each_with_index do |item, index|
          params[:client][:mo_savy_officials_attributes][index.to_s] = item
        end
      end

      client_param = params.require(:client).permit(
        :slug, :archived_slug, :code, :name_of_referee, :main_school_contact, :rated_for_id_poor, :what3words, :status, :country_origin,
        :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
        :birth_province_id, :initial_referral_date, :referral_source_id, :telephone_number,
        :referral_phone, :received_by_id, :followed_up_by_id, :current_family_id,
        :follow_up_date, :school_grade, :school_name, :current_address, :locality,
        :house_number, :street_number, :suburb, :description_house_landmark, :directions, :street_line1, :street_line2, :plot, :road, :postal_code, :district_id, :subdistrict_id,
        :has_been_in_orphanage, :has_been_in_government_care, :shared_service_enabled,
        :relevant_referral_information, :province_id, :city_id, :global_id, :external_id, :external_id_display, :mosvy_number,
        :state_id, :township_id, :rejected_note, :live_with, :profile, :remove_profile,
        :gov_city, :gov_commune, :gov_district, :gov_date, :gov_village_code, :gov_client_code,
        :gov_interview_village, :gov_interview_commune, :gov_interview_district, :gov_interview_city,
        :gov_caseworker_name, :gov_caseworker_phone, :gov_carer_name, :gov_carer_relationship, :gov_carer_home,
        :gov_carer_street, :gov_carer_village, :gov_carer_commune, :gov_carer_district, :gov_carer_city, :gov_carer_phone,
        :gov_information_source, :gov_referral_reason, :gov_guardian_comment, :gov_caseworker_comment, :commune_id, :village_id, :referral_source_category_id, :referee_id, :carer_id,
        :address_type, :phone_owner, :client_phone, :client_email, :referee_relationship, :outside, :outside_address, :location_description,
        :presented_id, :legacy_brcs_id, :id_number, :whatsapp, :other_phone_whatsapp, :other_phone_number, :brsc_branch, :current_island, :current_street,
        :current_po_box, :current_settlement, :current_resident_own_or_rent, :current_household_type,
        :island2, :street2, :po_box2, :settlement2, :preferred_language, :resident_own_or_rent2, :household_type2,
        :nickname, :relation_to_referee, :concern_is_outside, :concern_outside_address,
        :concern_province_id, :concern_district_id, :concern_commune_id, :concern_village_id,
        :concern_street, :concern_house, :concern_address, :concern_address_type,
        :concern_phone, :concern_phone_owner, :concern_email, :concern_email_owner, :concern_location,
        :national_id, :reason_for_referral, :for_testing, :from_referral_id,
        :birth_cert,
        :arrival_at,
        :flight_nb,
        :family_book,
        :marital_status,
        :nationality,
        :ethnicity,
        :location_of_concern,
        :neighbor_name,
        :neighbor_phone,
        :dosavy_name,
        :dosavy_phone,
        :chief_commune_name,
        :chief_commune_phone,
        :chief_village_name,
        :chief_village_phone,
        :ccwc_name,
        :ccwc_phone,
        :legal_team_name,
        :legal_representative_name,
        :legal_team_phone,
        :other_agency_name,
        :other_representative_name,
        :other_agency_phone,
        :type_of_trafficking,
        :education_background,
        :department,
        :passport,
        :passport_number,
        :national_id_number,
        :travel_doc,
        :referral_doc,
        :local_consent,
        :police_interview,
        :other_legal_doc,
        :remove_national_id_files,
        :remove_birth_cert_files,
        :remove_family_book_files,
        :remove_passport_files,
        :remove_travel_doc_files,
        :remove_referral_doc_files,
        :remove_local_consent_files,
        :remove_police_interview_files,
        :remove_other_legal_doc_files,
      *legal_doc_params,
      ratanak_achievement_program_staff_client_ids: [],
      birth_cert_files: [],
      family_book_files: [],
      passport_files: [],
      travel_doc_files: [],
      local_consent_files: [],
      police_interview_files: [],
      other_legal_doc_files: [],
      interviewee_ids: [],
      client_type_ids: [],
      user_ids: [],
      agency_ids: [],
      donor_ids: [],
      quantitative_case_ids: [],
      custom_field_ids: [],
      family_ids: [],
      mo_savy_officials_attributes: [:id, :name, :position, :_destroy],
      family_member_attributes: [:id, :family_id, :_destroy],
      tasks_attributes: [:name, :domain_id, :completion_date],
      client_needs_attributes: [:id, :rank, :need_id],
      client_problems_attributes: [:id, :rank, :problem_id]
      )

      field_settings.each do |field_setting|
        next if field_setting.group != 'client' || field_setting.required? || field_setting.visible?

        client_param.except!(field_setting.name.to_sym) unless field_setting.name == 'gender'
      end

      if params[:family_member]
        client_param[:family_member_attributes] = params[:family_member].permit(%i[id family_id])

        client_param[:family_member_attributes][:_destroy] = 1 if client_param[:family_member_attributes].present? && client_param.dig(:family_member_attributes, :family_id).blank?
      end

      client_param
    end

    def find_client_in_organization
      results = []
      similar_fields = Client.find_shared_client(params)
      { similar_fields: similar_fields }
    end

    def custom_data_params
      if params.dig(:custom_data, :properties)
        param_array = []
        params.dig(:custom_data, :properties).each { |k, v| param_array << [k, v.first.is_a?(Hash) ? v.first.keys : []] if v.is_a?(Array) }
        property_keys = params.dig(:custom_data, :properties).try(:keys)
        params.require(:custom_data).permit(
          properties: property_keys << param_array.to_h,
          form_builder_attachments_attributes: [:id, :name, { file: [] }]
        )
      else
        params.require(:custom_data).permit(
          form_builder_attachments_attributes: [:id, :name, { file: [] }]
        )
      end
    end

    def find_client_in_organization
      results = []
      similar_fields = Client.find_shared_client(params)
      { similar_fields: similar_fields }
    end

    def client_statistics
      @csi_statistics = CsiStatistic.new($client_data).assessment_domain_score.to_json
      @enrollments_statistics = ActiveEnrollmentStatistic.new($client_data).statistic_data.to_json
      { text: "#{@csi_statistics} & #{@enrollments_statistics}" }
    end

    def data
      assessment_domain_hash = {}
      client_data = []
      assessment_data.each do |assessment|
        assessment_domain_hash = AssessmentDomain.where(assessment_id: assessment.id).pluck(:domain_id, :score).to_h if assessment.assessment_domains.present?
        domain_scores = domains.ids.map { |domain_id| assessment_domain_hash.present? ? ["domain_#{domain_id}", assessment_domain_hash[domain_id]] : ["domain_#{domain_id}", ''] }
        total = 0
        assessment_domain_hash.each do |index, value|
          total += value || 0
        end

        client_hash = { slug: assessment.client.slug,
                       name: assessment.client.en_and_local_name,
                       'assessment-number': assessment.client.assessments.where(default: params[:default]).count,
                       date: assessment.created_at.strftime('%d %B %Y'),
                       'average-score': total == 0 ? nil : (total.fdiv(domain_scores.length())).round() }
        client_hash.merge!(domain_scores.to_h)
        client_data << client_hash
      end

      client_data
    end

    def assessment_data
      @assessments ||= fetch_assessments
    end

    def fetch_assessments
      basic_rules = JSON.parse(params[:basic_rules] || '{}')
      clients, _query = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability)).filter

      assessments = Assessment.joins(:client).where(default: params[:default], client_id: clients.ids)
      assessments = assessments.includes(:assessment_domains).order("#{sort_column} #{sort_direction}").references(:assessment_domains, :client)

      assessment_data = params[:length] != '-1' ? assessments.page(page).per(per_page) : assessments
    end

    def domains
      @domains ||= params[:default] == 'true' ? Domain.csi_domains : Domain.custom_csi_domains
    end

    def page
      params[:start].to_i / per_page + 1
    end

    def per_page
      params[:length].to_i > 0 ? params[:length].to_i : 10
    end

    def sort_column
      domains_fields = domains.map { |domain| 'assessment_domains.score' }
      columns = ["regexp_replace(clients.slug, '\\D*', '', 'g')::int", 'clients.given_name', 'clients.assessments_count', 'assessments.created_at', *domains_fields]
      columns[params[:order]['0']['column'].to_i]
    end

    def sort_direction
      params[:order]['0']['dir'] == 'desc' ? 'desc' : 'asc'
    end

    def adule_client_gender_count(clients, type = :male)
      clients.public_send(type).where('(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= ?', 18).count
    end

    def under_18_client_gender_count(clients, type = :male)
      clients.public_send(type).where('(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) < ?', 18).count
    end

    def other_client_gender_count(clients)
      clients.where("gender IS NULL OR (gender NOT IN ('male', 'female'))").count
    end
  end

  def check_is_referral_saved?(referral_id)
    return unless Referral.exists?(referral_id)

    referral = Referral.find(referral_id)
    return unless referral.saved?

    flash[:error] = 'This product already exists.'
    redirect_to referrals_path
  end
end
