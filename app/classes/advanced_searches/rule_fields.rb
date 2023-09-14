module AdvancedSearches
  class  RuleFields
    include AdvancedSearchHelper
    include ClientsHelper
    include ApplicationHelper

    def initialize(options = {})
      @user = options[:user]
      @called_in = options[:called_in]
      address_translation
    end

    def render
      group                 = format_header('basic_fields')
      number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_header(item), group) }
      text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), group) }
      date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), group) }
      drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, group) }
      default_domain_scores_options = enable_default_assessment? ? AdvancedSearches::DomainScoreFields.render : []
      custom_domain_scores_options = enable_custom_assessment? ? AdvancedSearches::CustomDomainScoreFields.render : []
      school_grade_options  = AdvancedSearches::SchoolGradeFields.render

      search_fields         = text_fields + drop_list_fields + number_fields + date_picker_fields

      search_fields.sort_by { |f| f[:label].downcase } + default_domain_scores_options + custom_domain_scores_options + school_grade_options
    end

    private

    def number_type_list
      ['family_id', 'age', 'time_in_cps', 'time_in_ngo']
    end

    def text_type_list
      ['given_name', 'family_name', 'local_given_name', 'local_family_name', 'family', 'slug', 'referral_phone', 'school_name', 'telephone_number', 'other_info_of_exit', 'exit_note', 'name_of_referee', 'main_school_contact', 'what3words', 'kid_id', 'code', *setting_country_fields[:text_fields]]
    end

    def date_type_list
      ['date_of_birth', 'initial_referral_date', 'follow_up_date', 'exit_date', 'accepted_date', 'case_note_date', 'created_at','date_of_referral']
    end

    def drop_down_type_list
      [
        ['created_by', user_select_options ],
        ['gender', gender_list],
        ['status', client_status],
        ['agency_name', agencies_options],
        ['received_by_id', user_select_options],
        ['referral_source_id', referral_source_options],
        ['followed_up_by_id', user_select_options],
        ['has_been_in_government_care', { true: 'Yes', false: 'No' }],
        ['has_been_in_orphanage', { true: 'Yes', false: 'No' }],
        ['user_id', user_select_options],
        ['donor_name', donor_options],
        ['birth_province_id', birth_provinces],
        ['case_note_type', case_note_type_options],
        ['exit_reasons', exit_reasons_options],
        ['exit_circumstance', { 'Exited Client': 'Exited Client', 'Rejected Referral': 'Rejected Referral' }],
        ['rated_for_id_poor', [Client::CLIENT_LEVELS, I18n.t('clients.level').values].transpose.to_h],
        *setting_country_fields[:drop_down_fields],
        ['referred_to', referral_to_options],
        ['referred_from', referral_from_options],
        ['referral_source_category_id', referral_source_category_options]
      ]
    end

    def gender_list
      [Client::GENDER_OPTIONS, Client::GENDER_OPTIONS.map { |value| I18n.t("default_client_fields.gender_list.#{value.gsub('other', 'other_gender')}") }].transpose.to_h
    end

    def case_note_type_options
      [CaseNote::INTERACTION_TYPE, I18n.t('.case_notes.form.type_options').values].transpose.map { |k, v| { k => v }  }
    end

    def exit_reasons_options
      ExitNgo::EXIT_REASONS.map { |s| { s => s }  }
    end

    def client_status
      Client::CLIENT_STATUSES.sort.map { |s| { s => s } }
    end

    def birth_provinces
      current_org = Organization.current.short_name
      provinces = []
      Organization.switch_to 'shared'
      Organization.pluck(:country).uniq.reject(&:blank?).each{ |country| provinces << Province.country_is(country).map{|p| { value: p.id.to_s, label: p.name, optgroup: country.titleize } } }
      Organization.switch_to current_org
      provinces.flatten
    end

    def subdistricts
      Subdistrict.order(:name).map { |s| { s.id.to_s => s.name } }
    end

    def townships
      Township.order(:name).map { |s| { s.id.to_s => s.name } }
    end

    def states
      State.order(:name).map { |s| { s.id.to_s => s.name } }
    end

    def referral_source_options
      ReferralSource.cache_referral_source_options
    end

    def referral_source_category_options
      if I18n.locale == :km
        ReferralSource.cache_local_referral_source_category_options
      else
        ReferralSource.cache_referral_source_category_options
      end
    end

    def agencies_options
      Agency.cache_agency_options
    end

    def user_select_options
      User.cached_user_select_options
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
      country = Setting.cache_first.country_name || 'cambodia'
      case country
      when 'cambodia'
        {
          text_fields: ['house_number', 'street_number'],
          drop_down_fields: addresses_mapping(@called_in)
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
      else
        {
          text_fields: ['house_number', 'street_number'],
          drop_down_fields: addresses_mapping(@called_in)
        }
      end
    end
  end
end
