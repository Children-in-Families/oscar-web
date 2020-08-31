module AdvancedSearches
  class ClientFields
    include AdvancedSearchHelper
    include ClientsHelper
    include ApplicationHelper
    include Pundit

    def initialize(options = {})
      @user = options[:user]
      @pundit_user = options[:pundit_user]
    end

    def render
      group                 = format_header('basic_fields')
      referee_group         = format_header('referee')
      carer_group           = format_header('carer')
      number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_header(item), group) }
      text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), group) }
      text_fields           << referee_text_fields.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), referee_group) }
      text_fields           << carer_text_fields.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), carer_group) }
      date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), group) }
      drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, group) }
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
      ['family_id', 'age', 'time_in_cps', 'time_in_ngo']
    end

    def text_type_list
      [
        # 'national_id_number',
        # 'passport_number',
        # 'neighbor_name',
        # 'neighbor_phone',
        # 'dosavy_name',
        # 'dosavy_phone',
        # 'chief_commune_name',
        # 'chief_commune_phone',
        # 'chief_village_name',
        # 'chief_village_phone',
        # 'ccwc_name',
        # 'ccwc_phone',
        # 'legal_team_name',
        # 'legal_representative_name',
        # 'legal_team_phone',
        # 'other_agency_name',
        # 'other_representative_name',
        # 'other_agency_phone',
        # 'department',
        # 'education_background',
        # 'id_number',
        # 'legacy_brcs_id',
        # 'other_phone_number',
        # 'current_household_type', 'household_type2', 'current_street', 'street2', 'current_po_box', 'po_box2',
        # 'brsc_branch', 'current_settlement', 'settlement2',
        'given_name', 'family_name',
        'local_given_name', 'local_family_name', 'family', 'slug', 'school_name',
        'other_info_of_exit', 'exit_note', 'main_school_contact', 'what3words', 'kid_id', 'code',
        'client_contact_phone', 'client_email_address', *setting_country_fields[:text_fields]
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
        'case_note_date', 'created_at', 'date_of_referral'
      ].compact
    end

    def drop_down_type_list
      [
        ['location_of_concern', Client.where.not(location_of_concern: [nil, '']).distinct.pluck(:location_of_concern).map{ |a| { a => a }}],
        # ['nationality', Client::NATIONALITIES.map{ |a| { a => a }}],
        # ['ethnicity', Client::ETHNICITY.map{ |a| { a => a }}],
        # ['type_of_trafficking', Client::TRAFFICKING_TYPES.map{ |a| { a => a }}],
        # ['marital_status', Client::MARITAL_STATUSES.map{ |a| { a => a }}],
        # ['presented_id', Client::BRC_PRESENTED_IDS.map{ |pi| { pi => pi }}],
        # ['preferred_language', Client::BRC_PREFERED_LANGS.map{ |pi| { pi => pi }}],
        # ['current_resident_own_or_rent', Client::BRC_RESIDENT_TYPES.map{ |rt| { rt => rt }}],
        # ['resident_own_or_rent2', Client::BRC_RESIDENT_TYPES.map{ |rt| { rt => rt }}],
        # ['current_island', Client::BRC_BRANCHES.map{ |island| { island => island }}],
        # ['island2', Client::BRC_BRANCHES.map{ |island| { island => island }}],
        ['created_by', user_select_options ],
        ['gender', gender_list],
        ['status', client_status],
        ['agency_name', agencies_options],
        ['received_by_id', received_by_options],
        ['referral_source_id', referral_source_options],
        ['followed_up_by_id', followed_up_by_options],
        ['has_been_in_government_care', { true: 'Yes', false: 'No' }],
        # ['national_id', { true: 'Yes', false: 'No' }],
        # ['birth_cert', { true: 'Yes', false: 'No' }],
        # ['family_book', { true: 'Yes', false: 'No' }],
        # ['passport', { true: 'Yes', false: 'No' }],
        # ['travel_doc', { true: 'Yes', false: 'No' }],
        # ['referral_doc', { true: 'Yes', false: 'No' }],
        # ['local_consent', { true: 'Yes', false: 'No' }],
        # ['police_interview', { true: 'Yes', false: 'No' }],
        # ['other_legal_doc', { true: 'Yes', false: 'No' }],
        # ['whatsapp', { true: 'Yes', false: 'No' }],
        ['has_been_in_orphanage', { true: 'Yes', false: 'No' }],
        ['user_id', user_select_options],
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
        ['phone_owner', get_sql_phone_owner]
      ].compact
    end

    def field_settings
      @field_settings = FieldSetting.all
    end

    def gender_list
      [Client::GENDER_OPTIONS.sort, I18n.t('default_client_fields.gender_list').values].transpose.to_h
    end

    def exit_reasons_options
      [ExitNgo::EXIT_REASONS.sort, I18n.t('client.exit_ngos.form.exit_reason_options').values].transpose.map{|k, v| { k => v }  }
    end

    def case_note_type_options
      [CaseNote::INTERACTION_TYPE, I18n.t('.case_notes.form.type_options').values].transpose.map{|k, v| { k => v }  }
    end

    def active_program_options
      program_ids = ClientEnrollment.active.pluck(:program_stream_id).uniq
      ProgramStream.where(id: program_ids).order(:name).map { |ps| { ps.id.to_s => ps.name } }
    end

    def enrolled_program_options
      program_ids = ClientEnrollment.pluck(:program_stream_id).uniq
      ProgramStream.where(id: program_ids).order(:name).map { |ps| { ps.id.to_s => ps.name } }
    end

    def client_status
      Client::CLIENT_STATUSES.sort.map { |s| { s => s.capitalize } }
    end

    def provinces
      Client.province_is.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def birth_provinces
      current_org = Organization.current.short_name
      provinces = []
      Organization.switch_to 'shared'
      ['Cambodia', 'Thailand', 'Lesotho', 'Myanmar', 'Uganda'].each{ |country| provinces << Province.country_is(country.downcase).map{|p| { value: p.id.to_s, label: p.name, optgroup: country } } }
      Organization.switch_to current_org
      provinces.flatten
    end

    def districts
      District.joins(:clients).pluck(:name, :id).uniq.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def communes
      Commune.joins(:clients, district: :province).distinct.map{|commune| ["#{commune.name_kh} / #{commune.name_en} (#{commune.code})", commune.id]}.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def villages
      Village.joins(:clients, commune: [district: :province]).distinct.map{|village| ["#{village.name_kh} / #{village.name_en} (#{village.code})", village.id]}.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def subdistricts
      Subdistrict.joins(:clients).pluck(:name, :id).uniq.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def townships
      Township.joins(:clients).pluck(:name, :id).uniq.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def states
      State.joins(:clients).pluck(:name, :id).uniq.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def received_by_options
      recevied_by_clients = @user.admin? || @user.manager? ? Client.is_received_by : Client.where(user_id: @user.id).is_received_by
      recevied_by_clients.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def referral_source_options
      referral_source_clients = @user.admin? ? Client.referral_source_is : Client.where(user_id: @user.id).referral_source_is
      referral_source_clients.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def referral_source_category_options
      ref_cat_ids = Client.pluck(:referral_source_category_id).compact.uniq
      if I18n.locale == :km
        ref_cat_kh_names = ReferralSource.where(id: ref_cat_ids).pluck(:name, :id)
        ref_cat_kh_names.sort.map{|s| {s[1].to_s => s[0]}}
      else
        ref_cat_en_names = ReferralSource.where(id: ref_cat_ids).pluck(:name_en, :id)
        ref_cat_en_names.sort.map{|s| {s[1].to_s => s[0]}}
      end
    end

    def get_type_of_services
      Service.only_children.pluck(:name, :id).uniq.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def followed_up_by_options
      followed_up_clients = @user.admin? || @user.manager? ? Client.is_followed_up_by : Client.where(user_id: @user.id).is_followed_up_by
      followed_up_clients.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def agencies_options
      Agency.order(:name).map { |s| { s.id.to_s => s.name } }
    end

    def user_select_options
      User.non_strategic_overviewers.order(:first_name, :last_name).map { |user| { user.id.to_s => user.name } }
    end

    def donor_options
      Donor.order(:name).map { |donor| { donor.id.to_s => donor.name } }
    end

    def referral_to_options
      orgs = Organization.oscar.map { |org| { org.short_name => org.full_name } }
      orgs << { "external referral" => "I don't see the NGO I'm looking for" }
    end

    def referral_from_options
      Organization.oscar.map { |org| { org.short_name => org.full_name } }
    end

    def setting_country_fields
      country = Setting.first.try(:country_name) || 'cambodia'
      case country
      when 'cambodia'
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

    def get_sql_address_types
      [Client::ADDRESS_TYPES, I18n.t('default_client_fields.address_types').values].transpose.to_h
    end

    def get_sql_phone_owner
      [Client::PHONE_OWNERS, I18n.t('default_client_fields.phone_owner').values].transpose.to_h
    end
  end
end
