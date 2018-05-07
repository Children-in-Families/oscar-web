module AdvancedSearches
  class  RuleFields
    include AdvancedSearchHelper

    def initialize(options = {})
      @user = options[:user]
    end

    def render
      group                 = format_header('basic_fields')
      number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_header(item), group) }
      text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), group) }
      date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), group) }
      drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, group) }
      domain_scores_options = AdvancedSearches::DomainScoreFields.render

      search_fields       = text_fields + drop_list_fields + number_fields + date_picker_fields

      search_fields.sort_by { |f| f[:label].downcase } + domain_scores_options
    end

    private

    def number_type_list
      ['family_id', 'age']
    end

    def text_type_list
      ['given_name', 'family_name', 'local_given_name', 'local_family_name', 'family', 'slug', 'referral_phone', 'school_name', 'school_grade', 'telephone_number', 'other_info_of_exit', 'exit_note', 'name_of_referee', 'main_school_contact', 'what3words', 'kid_id', 'code', *setting_country_fields[:text_fields]]
    end

    def date_type_list
      ['date_of_birth', 'initial_referral_date', 'follow_up_date', 'exit_date', 'accepted_date', 'case_note_date']
    end

    def drop_down_type_list
      [
        ['gender', { female: 'Female', male: 'Male' }],
        ['status', client_status],
        ['agency_name', agencies_options],
        ['received_by_id', user_select_options],
        ['referral_source_id', referral_source_options],
        ['followed_up_by_id', user_select_options],
        ['has_been_in_government_care', { true: 'Yes', false: 'No' }],
        ['has_been_in_orphanage', { true: 'Yes', false: 'No' }],
        ['user_id', user_select_options],
        ['form_title', client_custom_form_options],
        ['donor_id', donor_options],
        ['case_note_type', case_note_type_options],
        ['exit_reasons', exit_reasons_options],
        ['exit_circumstance', { 'Exited Client': 'Exited Client', 'Rejected Referral': 'Rejected Referral' }],
        ['rated_for_id_poor', { 'No': 'No', 'Level 1': 'Level 1', 'Level 2': 'Level 2', 'Level 3': 'Level 3' }],
        *setting_country_fields[:drop_down_fields]
      ]
    end

    def client_custom_form_options
      CustomField.client_forms.order(:form_title).map{ |c| { c.id.to_s => c.form_title }}
    end

    def case_note_type_options
      CaseNote::INTERACTION_TYPE
    end

    def exit_reasons_options
      ExitNgo::EXIT_REASONS.map{|s| { s => s }  }
    end

    def client_status
      Client::CLIENT_STATUSES.sort.map { |s| { s => s } }
    end

    def provinces
      Province.order(:name).map { |s| { s.id.to_s => s.name } }
    end

    def districts
      District.order(:name).map { |s| { s.id.to_s => s.name } }
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
      ReferralSource.order(:name).map { |s| { s.id.to_s => s.name } }
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

    def setting_country_fields
      country = Setting.first.try(:country_name) || 'cambodia'
      case country
      when 'cambodia'
        {
          text_fields: ['house_number', 'street_number', 'village', 'commune'],
          drop_down_fields: [['province_id', provinces], ['district_id', districts], ['birth_province_id', provinces]]
        }
      when 'lesotho'
        {
          text_fields: ['suburb', 'directions', 'description_house_landmark'],
          drop_down_fields: []
        }
      when 'thailand'
        {
          text_fields: ['plot', 'road', 'postal_code'],
          drop_down_fields: [['province_id', provinces], ['district_id', districts], ['subdistrict_id', subdistricts], ['birth_province_id', provinces]]
        }
      when 'myanmar'
        {
          text_fields: ['street_line1', 'street_line2'],
          drop_down_fields: [['township_id', townships], ['state_id', states]]
        }
      end
    end
  end
end
