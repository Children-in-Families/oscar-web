module AdvancedSearches
  class ClientFields
    include AdvancedSearchHelper
    include ClientsHelper
    include ApplicationHelper
    include AdvancedSearchFieldHelper
    include Pundit

    def initialize(options = {})
      @user = options[:user]
      @pundit_user = options[:pundit_user]
      @program_stream_ids = options[:program_stream_ids]
      address_translation
    end

    def render
      common_group = format_header('common_searches')
      group = format_header('basic_fields')
      care_plan_group = format_header('care_plan')
      referee_group = format_header('referee')
      carer_group = format_header('carer')
      legal_docs = format_header('legal_documents')
      case_history_group = format_header('case_history')
      family_group = format_header('family')
      case_note_group = format_header('case_note')
      other_group = format_header('other')

      number_fields = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_header(item), group) }
      number_fields += case_history_number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_header(item), case_history_group) }
      text_fields = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), group) }
      date_picker_fields = common_search_date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), common_group) }
      date_picker_fields += date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), group) }
      date_picker_fields += case_history_date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), case_history_group) }
      date_picker_fields += case_note_date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), case_note_group) }
      date_picker_fields += [['no_case_note_date', I18n.t('advanced_search.fields.no_case_note_date')]].map { |item| AdvancedSearches::CsiFields.date_between_only_options(item[0], item[1], case_note_group) }
      date_picker_fields += mapping_care_plan_date_lable_translation
      date_picker_fields += other_date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), other_group) }
      drop_list_fields = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, group) }
      drop_list_fields += care_plan_dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, care_plan_group) }
      drop_list_fields += referee_dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, referee_group) }
      drop_list_fields += carer_dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, carer_group) }
      drop_list_fields += legal_docs_dropdown.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, legal_docs) }
      drop_list_fields += family_dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, family_group) }
      drop_list_fields += case_history_dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, case_history_group) }
      drop_list_fields += case_note_dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, case_note_group) }
      drop_list_fields += other_dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, other_group) }
      csi_options = AdvancedSearches::CsiFields.render
      school_grade_options = AdvancedSearches::SchoolGradeFields.render
      default_domain_scores_options = enable_default_assessment? ? AdvancedSearches::DomainScoreFields.render : []
      custom_domain_scores_options = enable_custom_assessment? ? AdvancedSearches::CustomDomainScoreFields.render : []

      search_fields = text_fields.flatten + drop_list_fields + number_fields + date_picker_fields + AdvancedSearches::CaseNotes::CustomFields.new.render

      (search_fields.sort_by { |f| f[:label].downcase } + school_grade_options + csi_options + default_domain_scores_options + custom_domain_scores_options).select do |field|
        policy(Client).show?(field[:id].to_sym)
      end
    end

    private

    def number_type_list
      ['family_id', 'age']
    end

    def case_history_number_type_list
      ['referred_in', 'referred_out', 'time_in_ngo', 'time_in_cps']
    end

    def text_type_list
      [
        'given_name', 'flight_nb', 'local_given_name', 'slug', 'what3words', 'kid_id', 'code',
        'client_email_address', *setting_country_fields[:text_fields]
      ].compact
    end

    def referee_dropdown_list
      [
        ['referral_source_category_id', referral_source_category_options],
        ['referral_source_id', referral_source_options],
        ['referee_relationship', get_sql_referee_relationship]
      ]
    end

    def current_user
      @pundit_user
    end

    def common_search_date_type_list
      ['number_client_referred_gatekeeping', 'number_client_billable', 'client_rejected', 'active_clients']
    end

    def date_type_list
      [
        'date_of_birth', 'date_of_referral'
      ].compact
    end

    def case_history_date_type_list
      date_list = ['accepted_date', 'exit_date']
      enter_ngo_count = EnterNgo.group(:client_id).count.max.last
      if enter_ngo_count > 1
        (1..enter_ngo_count).each do |ordered_number|
          date_list.push("initial_referral_date_#{ordered_number}")
          date_list.push("follow_up_date_#{ordered_number}")
        end
      else
        date_list = ['initial_referral_date', 'follow_up_date', 'accepted_date', 'exit_date']
      end
      date_list
    end

    def case_note_date_type_list
      ['case_note_date']
    end

    def other_date_type_list
      ['created_at']
    end

    def drop_down_type_list
      yes_option = { true: 'Yes' }
      yes_no_options = { true: 'Yes', false: 'No' }
      fields = [
        ['location_of_concern', Client.cache_location_of_concern],
        ['gender', gender_list],
        ['status', client_status],
        ['ratanak_achievement_program_staff_client_ids', user_select_options],
        ['mo_savy_officials', mo_savy_officials_options],
        *rated_id_poor,
        *setting_country_fields[:drop_down_fields],
        ['address_type', get_sql_address_types],
        ['phone_owner', get_sql_phone_owner]
      ].compact
    end

    def legal_docs_dropdown
      yes_no_options = { true: 'Yes', false: 'No' }
      legal_doc_fields.map { |field| [field, yes_no_options] }
    end

    def care_plan_dropdown_list
      yes_option = { true: 'Yes' }
      [
        ['incomplete_care_plan', yes_option]
      ]
    end

    def carer_dropdown_list
      [
        ['carer_relationship_to_client', list_carer_client_relations]
      ]
    end

    def family_dropdown_list
      [
        ['family_type', family_type_list]
      ]
    end

    def case_history_dropdown_list
      yes_no_options = { true: 'Yes', false: 'No' }
      enter_ngo_count = EnterNgo.group(:client_id).count.max.last

      users_list = [
        ['user_id', user_select_options],
        ['exit_circumstance', { 'Exited Client': 'Exited Client', 'Rejected Referral': 'Rejected Referral' }],
        ['referred_from', referral_from_options],
        ['referred_to', referral_to_options],
        ['exit_reasons', exit_reasons_options],
        ['active_program_stream', active_program_options],
        ['enrolled_program_stream', enrolled_program_options],
        ['donor_name', donor_options],
        ['has_been_in_orphanage', yes_no_options],
        ['has_been_in_government_care', yes_no_options]
      ]

      if enter_ngo_count > 1
        user_list = []
        (1..enter_ngo_count).each do |ordered_number|
          user_list.push(["received_by_id_#{ordered_number}", received_by_options])
          user_list.push(["followed_up_by_id_#{ordered_number}", followed_up_by_options])
        end
      else
        user_list = [['followed_up_by_id', followed_up_by_options], ['received_by_id', received_by_options]]
      end

      users_list.push(*user_list)
    end

    def case_note_dropdown_list
      yes_no_options = { true: 'Yes', false: 'No' }
      [
        ['case_note_type', case_note_type_options],
        ['no_case_note', yes_no_options]
      ]
    end

    def other_dropdown_list
      yes_no_options = { true: 'Yes', false: 'No' }
      [
        ['agency_name', agencies_options],
        ['created_by', user_select_options],
        ['type_of_service', get_type_of_services],
        ['has_overdue_forms', yes_no_options],
        ['has_overdue_task', yes_no_options]
      ]
    end

    def field_settings
      @field_settings = FieldSetting.cache_all
    end

    def gender_list
      [Client::GENDER_OPTIONS, Client::GENDER_OPTIONS.map { |value| I18n.t("default_client_fields.gender_list.#{value.gsub('other', 'other_gender')}") }].transpose.to_h
    end

    def exit_reasons_options
      [ExitNgo::EXIT_REASONS.sort, I18n.t('client.exit_ngos.form.exit_reason_options').values].transpose.map { |k, v| { k => v } }
    end

    def case_note_type_options
      [CaseNote::INTERACTION_TYPE, I18n.t('.case_notes.form.type_options').values].transpose.map { |k, v| { k => v } }
    end

    def active_program_options
      ClientEnrollment.cache_active_program_options
    end

    def enrolled_program_options
      ProgramStream.cache_program_steam_by_enrollment.map { |ps| { ps.id.to_s => ps.name } }
    end

    def mo_savy_officials_options
      MoSavyOfficial.all.map { |item| { item.id.to_s => item.name } }
    end

    def client_status
      Client::CLIENT_STATUSES.sort.map { |s| { s => s.capitalize } }
    end

    def provinces
      Province.cached_dropdown_list_option
    end

    def birth_provinces
      Apartment::Tenant.switch('shared') do
        Organization.pluck(:country).uniq.reject(&:blank?).map do |country|
          Province.cache_by_country(country).map { |p| { value: p.id.to_s, label: p.name, optgroup: country.titleize } }
        end.flatten
      end
    end

    def districts
      District.cached_dropdown_list_option
    end

    def communes
      Commune.cache_by_client_district_province_and_mapping_names
    end

    def villages
      Village.cache_village_name_by_client_commune_district_province
    end

    def subdistricts
      Subdistrict.cached_dropdown_list_option
    end

    def townships
      Township.cached_dropdown_list_option
    end

    def states
      State.cached_dropdown_list_option
    end

    def get_type_of_services
      Service.cache_only_child_services
    end

    def agencies_options
      Agency.cache_agency_options
    end

    def donor_options
      Donor.cache_donor_options
    end

    def referral_to_options
      orgs = Organization.cache_mapping_ngo_names
      orgs << { 'MoSVY External System' => 'MoSVY External System' }
      orgs << { 'external referral' => "I don't see the NGO I'm looking for" }
    end

    def referral_from_options
      orgs = Organization.cache_mapping_ngo_names
      orgs << { 'MoSVY External System' => 'MoSVY External System' }
    end

    def setting_country_fields
      country = Setting.first.country_name || 'cambodia'
      case country
      when 'lesotho'
        {
          text_fields: ['suburb', 'directions', 'description_house_landmark'],
          drop_down_fields: []
        }
      when 'thailand'
        {
          text_fields: ['plot', 'road', 'postal_code'],
          drop_down_fields: [['province_id', provinces], ['district_id', districts], ['subdistrict_id', subdistricts], ['birth_province_id', birth_provinces]]
        }
      when 'myanmar'
        {
          text_fields: ['street_line1', 'street_line2'],
          drop_down_fields: [['township_id', townships], ['state_id', states]]
        }
      when 'uganda'
        {
          text_fields: ['house_number', 'street_number'],
          drop_down_fields: [['province_id', provinces], ['district_id', districts], ['birth_province_id', birth_provinces], ['commune_id', communes], ['village_id', villages]]
        }
      else
        {
          text_fields: ['house_number', 'street_number'],
          drop_down_fields: [
            ['province_id', provinces],
            ['district_id', districts],
            ['birth_province_id', birth_provinces],
            ['commune_id', communes],
            ['village_id', villages]
          ]
        }
      end
    end

    def rated_id_poor
      if Setting.first.country_name == 'cambodia'
        [['rated_for_id_poor', [Client::CLIENT_LEVELS, I18n.t('clients.level').values].transpose.to_h]]
      else
        []
      end
    end

    def get_sql_referee_relationship
      [Client::REFEREE_RELATIONSHIPS, I18n.t('default_client_fields.referee_relationship').values].transpose.to_h
    end

    def list_carer_client_relations
      [Carer::CLIENT_RELATIONSHIPS, Carer::CLIENT_RELATIONSHIPS].transpose.to_h
    end

    def get_sql_address_types
      [Client::ADDRESS_TYPES, I18n.t('default_client_fields.address_types').values].transpose.to_h
    end

    def get_sql_phone_owner
      [Client::PHONE_OWNERS, I18n.t('default_client_fields.phone_owner').values].transpose.to_h
    end

    def family_type_list
      Family.mapping_family_type_translation.to_h
    end

    def mo_savy_officials_options
      MoSavyOfficial.cache_all.map { |item| { item.id.to_s => item.name } }
    end
  end
end
