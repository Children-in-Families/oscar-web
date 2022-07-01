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
      address_translation
    end

    def render
      group                 = format_header('basic_fields')
      referee_group         = format_header('referee')
      carer_group           = format_header('carer')
      legal_docs            = format_header('legal_documents')

      number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_header(item), group) }
      text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), group) }
      text_fields           << referee_text_fields.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), referee_group) }
      text_fields           << carer_text_fields.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), carer_group) }
      date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), group) }
      date_picker_fields    += [['no_case_note_date', I18n.t('advanced_search.fields.no_case_note_date')]].map{ |item| AdvancedSearches::CsiFields.date_between_only_options(item[0], item[1], group) }
      date_picker_fields    += mapping_care_plan_date_lable_translation
      drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, group) }
      drop_list_fields      += carer_dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, carer_group) }
      drop_list_fields      += legal_docs_dropdown.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, legal_docs) }
      csi_options           = AdvancedSearches::CsiFields.render
      school_grade_options  = AdvancedSearches::SchoolGradeFields.render
      default_domain_scores_options = enable_default_assessment? ? AdvancedSearches::DomainScoreFields.render : []
      custom_domain_scores_options  = enable_custom_assessment? ? AdvancedSearches::CustomDomainScoreFields.render : []

      search_fields = text_fields.flatten + drop_list_fields + number_fields + date_picker_fields

      (search_fields.sort_by { |f| f[:label].downcase } + school_grade_options + csi_options + default_domain_scores_options + custom_domain_scores_options).select do |field|
        policy(Client).show?(field[:id].to_sym)
      end
    end

    private

    def number_type_list
      ['family_id', 'age', 'time_in_cps', 'time_in_ngo', 'referred_in', 'referred_out']
    end

    def text_type_list
      [
        'given_name', 'family_name', 'flight_nb',
        'local_given_name', 'local_family_name', 'family', 'slug', 'school_name',
        'other_info_of_exit', 'exit_note', 'main_school_contact', 'what3words', 'kid_id', 'code',
        'client_phone', 'client_email_address', *setting_country_fields[:text_fields]
      ].compact
    end

    def referee_text_fields
      ['referee_name', 'referee_phone', 'referee_email']
    end

    def carer_text_fields
      ['carer_name', 'carer_phone', 'carer_email']
    end

    def current_user
      @pundit_user
    end

    def date_type_list
      [
        'date_of_birth', 'initial_referral_date', 'follow_up_date', 'exit_date', 'accepted_date',
        'case_note_date', 'created_at', 'date_of_referral', 'active_clients', 'active_client_program',
        'number_client_referred_gatekeeping', 'number_client_billable', 'arrival_at'
      ].compact
    end

    def drop_down_type_list
      yes_no_options = { true: 'Yes', false: 'No' }
      better_same_worse_options = { better: 'Better', same: 'The same', worse: 'Worse' }
      fields = [
        ['location_of_concern', Client.cache_location_of_concern],
        ['created_by', user_select_options ],
        ['gender', gender_list],
        ['status', client_status],
        ['agency_name', agencies_options],
        ['received_by_id', received_by_options],
        ['referral_source_id', referral_source_options],
        ['followed_up_by_id', followed_up_by_options],
        ['has_been_in_government_care', yes_no_options],
        ['has_overdue_assessment', yes_no_options],
        ['has_overdue_forms', yes_no_options],
        ['has_overdue_task', yes_no_options],
        ['no_case_note', yes_no_options],
        ['has_been_in_orphanage', yes_no_options],
        ['user_id', user_select_options],
        ['ratanak_achievement_program_staff_client_ids', user_select_options],
        ['mo_savy_officials', mo_savy_officials_options],
        ['donor_name', donor_options],
        ['active_program_stream', active_program_options],
        ['enrolled_program_stream', enrolled_program_options],
        ['case_note_type', case_note_type_options],
        ['exit_reasons', exit_reasons_options],
        ['exit_circumstance', {'Exited Client': 'Exited Client', 'Rejected Referral': 'Rejected Referral'}],
        *rated_id_poor,
        *setting_country_fields[:drop_down_fields],
        ['referred_to', referral_to_options],
        ['referred_from', referral_from_options],
        ['referral_source_category_id', referral_source_category_options],
        ['type_of_service', get_type_of_services],
        ['referee_relationship', get_sql_referee_relationship],
        ['address_type', get_sql_address_types],
        ['phone_owner', get_sql_phone_owner],
        ['family_type', family_type_list],
        ['assessment_condition_last_two', better_same_worse_options],
        ['assessment_condition_first_last', better_same_worse_options]
      ].compact
    end

    def legal_docs_dropdown
      yes_no_options = { true: 'Yes', false: 'No' }
      legal_doc_fields.map{|field| [field, yes_no_options] }
    end

    def carer_dropdown_list
      [
        ['carer_relationship_to_client', list_carer_client_relations]
      ]
    end

    def field_settings
      @field_settings = FieldSetting.cache_all
    end

    def gender_list
      [Client::GENDER_OPTIONS, Client::GENDER_OPTIONS.map{|value| I18n.t("default_client_fields.gender_list.#{ value.gsub('other', 'other_gender') }") }].transpose.to_h
    end

    def exit_reasons_options
      [ExitNgo::EXIT_REASONS.sort, I18n.t('client.exit_ngos.form.exit_reason_options').values].transpose.map{|k, v| { k => v }  }
    end

    def case_note_type_options
      [CaseNote::INTERACTION_TYPE, I18n.t('.case_notes.form.type_options').values].transpose.map{|k, v| { k => v }  }
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
      current_org = Organization.current.short_name
      provinces = []
      Organization.switch_to 'shared'
      Organization.pluck(:country).uniq.reject(&:blank?).each{ |country| provinces << Province.country_is(country).map{|p| { value: p.id.to_s, label: p.name, optgroup: country.titleize } } }
      Organization.switch_to current_org
      provinces.flatten
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
      orgs << { "MoSVY External System" => "MoSVY External System" }
      orgs << { "external referral" => "I don't see the NGO I'm looking for" }
    end

    def referral_from_options
      orgs = Organization.cache_mapping_ngo_names
      orgs << { "MoSVY External System" => "MoSVY External System" }
    end

    def setting_country_fields
      country = Setting.cache_first.try(:country_name) || 'cambodia'
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
          drop_down_fields: [['province_id', provinces], ['district_id', districts], ['birth_province_id', birth_provinces], ['commune_id', communes], ['village_id', villages] ]
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
      if Setting.cache_first.country_name == 'cambodia'
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
      MoSavyOfficial.all.map { |item| { item.id.to_s => item.name } }
    end
  end
end
