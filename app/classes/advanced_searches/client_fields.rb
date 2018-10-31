module AdvancedSearches
  class  ClientFields
    include AdvancedSearchHelper
    include ClientsHelper

    def initialize(options = {})
      @user = options[:user]
    end

    def render
      group                 = format_header('basic_fields')
      number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_header(item), group) }
      text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), group) }
      date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), group) }
      drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, group) }
      domain_scores_options = enable_assessment_setting? ? AdvancedSearches::DomainScoreFields.render : []
      school_grade_options  = AdvancedSearches::SchoolGradeFields.render

      search_fields         = text_fields + drop_list_fields + number_fields + date_picker_fields

      search_fields.sort_by { |f| f[:label].downcase } + domain_scores_options + school_grade_options
    end

    private

    def number_type_list
      ['family_id', 'age', 'time_in_care']
    end

    def text_type_list
      ['given_name', 'family_name', 'local_given_name', 'local_family_name', 'family', 'slug', 'referral_phone', 'school_name', 'telephone_number', 'other_info_of_exit', 'exit_note', 'name_of_referee', 'main_school_contact', 'what3words', 'kid_id', 'code', *setting_country_fields[:text_fields]]
    end

    def date_type_list
      ['date_of_birth', 'initial_referral_date', 'follow_up_date', 'exit_date', 'accepted_date', 'case_note_date', 'created_at']
    end

    def drop_down_type_list
      [
        ['created_by', user_select_options ],
        ['gender', { male: 'Male', female: 'Female', unknown: 'Unknown' }],
        ['status', client_status],
        ['agency_name', agencies_options],
        ['received_by_id', received_by_options],
        ['referral_source_id', referral_source_options],
        ['followed_up_by_id', followed_up_by_options],
        ['has_been_in_government_care', { true: 'Yes', false: 'No' }],
        ['has_been_in_orphanage', { true: 'Yes', false: 'No' }],
        ['user_id', user_select_options],
        ['donor_name', donor_options],
        ['active_program_stream', active_program_options],
        ['enrolled_program_stream', enrolled_program_options],
        ['case_note_type', case_note_type_options],
        ['exit_reasons', exit_reasons_options],
        ['exit_circumstance', {'Exited Client': 'Exited Client', 'Rejected Referral': 'Rejected Referral'}],
        ['rated_for_id_poor', {'No': 'No', 'Level 1': 'Level 1', 'Level 2': 'Level 2'}],
        *setting_country_fields[:drop_down_fields],
        ['referred_to', referral_to_options],
        ['referred_from', referral_from_options]
      ]
    end

    def exit_reasons_options
      ExitNgo::EXIT_REASONS.map{|s| { s => s }  }
    end

    def case_note_type_options
      CaseNote::INTERACTION_TYPE
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
      ['Cambodia', 'Thailand', 'Lesotho', 'Myanmar'].each{ |country| provinces << Province.country_is(country.downcase).map{|p| { value: p.id.to_s, label: p.name, optgroup: country } } }
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
          drop_down_fields: [['province_id', provinces], ['district_id', districts], ['birth_province_id', birth_provinces], ['commune_id', communes], ['village_id', villages] ]
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
      end
    end
  end
end
