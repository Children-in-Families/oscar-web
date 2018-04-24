module AdvancedSearches
  class  ClientFields
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

      search_fields         = text_fields + drop_list_fields + number_fields + date_picker_fields

      search_fields.sort_by { |f| f[:label].downcase } + domain_scores_options
    end

    private

    def number_type_list
      # ['code', 'family_id', 'age', 'id_poor']
      ['family_id', 'age']
    end

    def text_type_list
      ['given_name', 'family_name', 'local_given_name', 'local_family_name', 'family', 'slug', 'referral_phone', 'house_number', 'street_number', 'village', 'commune', 'school_name', 'school_grade', 'telephone_number', 'other_info_of_exit', 'exit_note', 'name_of_referee', 'main_school_contact', 'what3words', 'kid_id', 'code']
    end

    def date_type_list
      ['placement_date', 'date_of_birth', 'initial_referral_date', 'follow_up_date', 'referred_to_ec', 'referred_to_fc', 'referred_to_kc', 'exit_ec_date', 'exit_fc_date', 'exit_kc_date', 'exit_date', 'accepted_date', 'case_note_date']
    end

    def drop_down_type_list
      [
        ['gender', { female: 'Female', male: 'Male' }],
        ['status', client_status],
        ['case_type', { EC: 'EC', FC: 'FC',  KC: 'KC' }],
        ['agency_name', agencies_options],
        ['received_by_id', received_by_options],
        ['birth_province_id', birth_provinces],
        ['province_id', provinces],
        ['district_id', districts],
        ['referral_source_id', referral_source_options],
        ['followed_up_by_id', followed_up_by_options],
        ['has_been_in_government_care', { true: 'Yes', false: 'No' }],
        ['has_been_in_orphanage', { true: 'Yes', false: 'No' }],
        ['user_id', user_select_options],
        ['form_title', client_custom_form_options],
        ['donor_id', donor_options],
        ['program_stream', program_options],
        ['case_note_type', case_note_type_options],
        ['exit_reasons', exit_reasons_options],
        ['exit_circumstance', {'Exited Client': 'Exited Client', 'Rejected Referral': 'Rejected Referral'}],
        ['rated_for_id_poor', {'No': 'No', 'Level 1': 'Level 1', 'Level 2': 'Level 2', 'Level 3': 'Level 3'}]
      ]
    end

    def exit_reasons_options
      ExitNgo::EXIT_REASONS.map{|s| { s => s }  }
    end

    def case_note_type_options
      CaseNote::INTERACTION_TYPE
    end

    def program_options
      ProgramStream.joins(:client_enrollments).where("client_enrollments.program_stream_id = program_streams.id AND client_enrollments.status = 'Active'").order(:name).map { |ps| { ps.id.to_s => ps.name } }.uniq
    end

    def client_custom_form_options
      CustomField.joins(:custom_field_properties).client_forms.uniq.map{ |c| { c.id.to_s => c.form_title }}
    end

    def client_status
      Client::CLIENT_STATUSES.sort.map { |s| { s => s.capitalize } }
    end

    def provinces
      Client.province_is.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def birth_provinces
      Client.birth_province_is.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def districts
      District.joins(:clients).pluck(:name, :id).uniq.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def received_by_options
      recevied_by_clients = @user.admin? ? Client.is_received_by : Client.where(user_id: @user.id).is_received_by
      recevied_by_clients.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def referral_source_options
      referral_source_clients = @user.admin? ? Client.referral_source_is : Client.where(user_id: @user.id).referral_source_is
      referral_source_clients.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def followed_up_by_options
      followed_up_clients = @user.admin? ? Client.is_followed_up_by : Client.where(user_id: @user.id).is_followed_up_by
      followed_up_clients.sort.map{|s| {s[1].to_s => s[0]}}
    end

    def agencies_options
      Agency.order(:name).map { |s| { s.id.to_s => s.name } }
    end

    def user_select_options
      User.has_clients.order(:first_name, :last_name).map { |user| { user.id.to_s => user.name } }
    end

    def donor_options
      Donor.order(:name).map { |donor| { donor.id.to_s => donor.name } }
    end
  end
end
