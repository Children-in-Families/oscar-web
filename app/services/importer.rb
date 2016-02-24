module Importer
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = '/Users/bunhouth/Workspace/CurrentProject/Rotati/CIF-DB-1.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(1).each_with_index {|header,i|
        headers[header] = i
      }
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name      = workbook.row(row)[headers['Name']]
        last_name       = workbook.row(row)[headers['Surname']]
        province_name   = workbook.row(row)[headers['Province']]
        job_title       = workbook.row(row)[headers['Job Title']]
        department_name = workbook.row(row)[headers['Department']]
        start_date      = workbook.row(row)[headers['Start Date']]
        phone           = workbook.row(row)[headers['Phone Number']]
        email           = workbook.row(row)[headers['Email']]
        email           = Faker::Internet.email if email.blank?

        province_autocorrect = ProvinceAutocorrect.new
        province             = Province.find_or_create_by(name: province_autocorrect.validate(province_name))
        department           = Department.find_or_create_by(name: department_name)

        user                 = province.users.create(
          first_name: first_name,
          last_name: last_name,
          start_date: start_date,
          job_title: job_title,
          department: department,
          mobile: phone,
          email: email.split(';')[0],
          password: Devise.friendly_token.first(8)
        )
      end
    end


    def fc_families
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        family_id                  = workbook.row(row)[headers['FC Family ID']]
        household_name             = workbook.row(row)[headers['FC Household Name']]
        province_name              = workbook.row(row)[headers['Province']]
        caregiver_information      = workbook.row(row)[headers['Caregiver Information']]
        significant_family_members = workbook.row(row)[headers['Significant Family Members']]
        household_income           = workbook.row(row)[headers['Approx. Household Income']]
        dependable_income          = workbook.row(row)[headers['Dependable Income?']]
        child_female               = workbook.row(row)[headers['#Child Female']]
        child_male                 = workbook.row(row)[headers['#Child Male']]
        adult_female               = workbook.row(row)[headers['#Adult Female']]
        adult_male                 = workbook.row(row)[headers['#Adult Male']]
        first_contract_date        = workbook.row(row)[headers['Date First Contract']]

        province_autocorrect = ProvinceAutocorrect.new
        province             = Province.find_or_create_by(name: province_autocorrect.validate(province_name))

        Family.find_or_create_by(
          family_type: 'foster',
          code: family_id,
          name: household_name,
          province: province,
          caregiver_information: caregiver_information,
          significant_family_member_count: significant_family_members,
          household_income: household_income,
          dependable_income: word_to_boolean(dependable_income),
          female_children_count: child_female,
          male_children_count: child_male,
          female_adult_count: adult_female,
          male_adult_count: adult_male,
          contract_date: first_contract_date.try(:to_date)
        )
      end
    end

    def kc_families
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        family_id                 = workbook.row(row)[headers['KC Family ID']]
        significant_family_member = workbook.row(row)[headers['Significant Family Members']]
        household_income          = workbook.row(row)[headers['Approx. Household Income']]
        dependable_income         = workbook.row(row)[headers['Dependable Income?']]
        adult_male                = workbook.row(row)[headers['#Adult Male']]
        adult_female              = workbook.row(row)[headers['#Adult Female']]
        child_male                = workbook.row(row)[headers['#Child Male']]
        child_female              = workbook.row(row)[headers['#Child Female']]
        first_contract_date       = workbook.row(row)[headers['Date First Contract']]

        Family.create(
          code: family_id,
          significant_family_member_count: significant_family_member,
          household_income: household_income,
          dependable_income: word_to_boolean(dependable_income),
          female_children_count: child_female,
          male_children_count: child_male,
          female_adult_count: adult_female,
          male_adult_count: adult_male,
          contract_date: first_contract_date.try(:to_date)
        )
      end
    end

    def ec
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name                        = workbook.row(row)[headers['Name']]
        status                      = workbook.row(row)[headers['Status']]
        province_name               = workbook.row(row)[headers['Province']]
        village_name                = workbook.row(row)[headers['Village']]
        gender                      = workbook.row(row)[headers['(M/F)']]
        dob                         = workbook.row(row)[headers['Date of Birth']]
        date_initial_referral       = workbook.row(row)[headers['Date Initial Referral']]
        follow_up_date              = workbook.row(row)[headers['Follow Up Date:']]
        reason_for_referral         = workbook.row(row)[headers['Reason for Referral']]
        received_by_name            = workbook.row(row)[headers['Recieved By:']]
        follow_up_by                = workbook.row(row)[headers['Followed Up By:']]
        agencies_involved           = workbook.row(row)[headers['Agencies currently involved']]
        current_address             = workbook.row(row)[headers['Child\'s Current Address']]
        has_been_in_orphanage       = workbook.row(row)[headers['Has Child been in orphanage']]
        relevant_case_information   = workbook.row(row)[headers['Relevant Case Information']]
        referral_phone              = workbook.row(row)[headers['Referral Phone Number']]
        referral_source             = workbook.row(row)[headers['Referral Source']]
        start_date                  = workbook.row(row)[headers['Date EC Start']]
        exit_date                   = workbook.row(row)[headers['Date EC Exit']]

        received_by           = User.find_by(last_name: received_by_name)
        followed_up_by        = User.find_by(last_name: follow_up_by)
        referral_source       = ReferralSource.find_or_create_by(name: referral_source)
        province_autocorrect  = ProvinceAutocorrect.new
        province              = Province.find_or_create_by(name: province_autocorrect.validate(province_name))
        creator               = received_by

        client = Client.find_or_create_by(
          first_name: name,
          status: 'Active EC',
          province_id: province.try(:id),
          gender: gender,
          date_of_birth: dob.try(:to_date),
          initial_referral_date: date_initial_referral.try(:to_date),
          follow_up_date: follow_up_date.try(:to_date),
          reason_for_referral: reason_for_referral,
          received_by_id: received_by.try(:id),
          followed_up_by_id: followed_up_by.try(:id),
          current_address: current_address,
          has_been_in_orphanage: word_to_boolean(has_been_in_orphanage),
          relevant_referral_information: relevant_case_information,
          referral_phone: referral_phone,
          referral_source_id: referral_source.try(:id),
          user_id: creator.try(:id),
          state: 'accepted'
        )

        client.cases.create(
          start_date: start_date,
          exit_date: exit_date,
          province_id: province.try(:id),
          user_id: creator.try(:id)
        )

        if agencies_involved.present?
          agencies_involved.split(',').each do |agency|
            agency = Agency.find_or_create_by(name: agency.strip)
            client.agencies << agency
          end
          client.save
        end

        if creator.nil?
          logger = Logger.new('log/import.log')
          logger.info "Create Client with user_id nil on client #{client.id}"
        end
      end
    end

    def kc_managements
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        staff_name                        = workbook.row(row)[headers['Staff ID']]
        name                              = workbook.row(row)[headers['Name']]
        code                              = workbook.row(row)[headers['ID #']]
        gender                            = workbook.row(row)[headers['Male/ Female (M/F)']]
        family_id                         = workbook.row(row)[headers['KC Family ID']]
        status                            = workbook.row(row)[headers['Status']]
        dob                               = workbook.row(row)[headers['Date of Birth']]
        grade                             = workbook.row(row)[headers['Grade']]
        school                            = workbook.row(row)[headers['School']]
        background                        = workbook.row(row)[headers['Child\'s Background (Breif)']]
        current_address                   = workbook.row(row)[headers['Current Address']]
        partner_name                      = workbook.row(row)[headers['Ongoing Partner']]
        village                           = workbook.row(row)[headers['Village']]
        province_name                     = workbook.row(row)[headers['Province']]
        support_ammount                   = workbook.row(row)[headers['CIF Support Amount']]
        support_notes                     = workbook.row(row)[headers['CIF Support Notes']]
        is_in_government_care             = workbook.row(row)[headers['Has Child been in Gov\'t Care?']]
        has_been_in_orphanage             = workbook.row(row)[headers['Has Child been in orphanage?']]
        is_receiving_additional_benefits  = workbook.row(row)[headers['Is the Child receiving any support besides CIF?']]
        able                              = workbook.row(row)[headers['ABLE']]
        initial_assessment_date           = workbook.row(row)[headers['Date Initial Assessment']]
        case_conference_date              = workbook.row(row)[headers['Date Case Conference']]
        date_of_placement                 = workbook.row(row)[headers['Date of Placement']]
        exit_date                         = workbook.row(row)[headers['Date Exit From Program']]
        reason_for_exit                   = workbook.row(row)[headers['Reason For Exit?']]
        signed_contract                   = workbook.row(row)[headers['SIgned Contract']]
        case_length                       = workbook.row(row)[headers['Case Length']]



        province_autocorrect = ProvinceAutocorrect.new
        province             = Province.find_or_create_by(name: province_autocorrect.validate(province_name))
        ongoing_partner      = Partner.find_or_create_by(name: partner_name)
        staff                = User.find_by(last_name: staff_name)
        family               = Family.find_by(code: family_id)
        creator              = staff

        client                              = Client.find_or_initialize_by(first_name: name, date_of_birth: dob.try(:to_date), gender: gender)
        client.province_id                  = province.try(:id)
        client.user_id                      = creator.try(:id)
        client.code                         = code
        client.status                       = 'Active KC'
        client.current_address              = [village, current_address].join(', ')
        client.state                        = 'accepted'
        client.has_been_in_government_care  = word_to_boolean(is_in_government_care)
        client.has_been_in_orphanage        = word_to_boolean(has_been_in_orphanage)
        client.school_grade                 = grade
        client.school_name                  = school
        client.able                         = word_to_boolean(able)
        client.is_receiving_additional_benefits = word_to_boolean(is_receiving_additional_benefits)
        client.background                   = background

        client.save

        kc = Case.new(
          support_amount: support_ammount,
          support_note: support_notes,
          case_type: 'KC',
          status: status,
          partner_id: ongoing_partner.try(:id),
          family: family,
          user_id: creator.try(:id),
          initial_assessment_date: initial_assessment_date,
          case_length: case_length,
          case_conference_date: case_conference_date,
          placement_date: date_of_placement,
          exit_date: exit_date,
          exit_note: reason_for_exit,
          client_id: client.id,
          province_id: province.try(:id)
        )

        family.nil? ? kc.save(validate: false) : kc.save

        if signed_contract.present?
          CSV.parse_line(signed_contract.to_s).each do  |signed_date|
            kc.case_contracts.create!(signed_on: signed_date.to_date) if signed_date.present?
          end
        end

        if creator.nil?
          logger = Logger.new('log/import.log')
          logger.info "Create Client with user_id nil on client #{client.id}"
        end
      end
    end

    def fc_managements
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name                    = workbook.row(row)[headers['Name']]
        code                    = workbook.row(row)[headers['ID #']]
        status                  = workbook.row(row)[headers['Status']]
        staff_name              = workbook.row(row)[headers['Staff Name']]
        fc_family_info          = workbook.row(row)[headers['FC Family Information']]
        dob                     = workbook.row(row)[headers['Date of Birth']]
        village                 = workbook.row(row)[headers['Village']]
        ongoing_partner_name    = workbook.row(row)[headers['Ongoing Partner']]
        date_of_placement       = workbook.row(row)[headers['Date of Placement']]
        time_in_care            = workbook.row(row)[headers['Time In Care']]
        province_name           = workbook.row(row)[headers['Province']]
        support_amount          = workbook.row(row)[headers['CIF Support Amount']]
        support_note            = workbook.row(row)[headers['CIF Support Notes']]
        gender                  = workbook.row(row)[headers['Male / Female (M/F)']]
        grade                   = workbook.row(row)[headers['Grade']]
        has_been_in_orphanage   = workbook.row(row)[headers['Has Child been in orphanage?']]
        school                  = workbook.row(row)[headers['School']]
        is_in_government_care   = workbook.row(row)[headers['Has Child been in Gov\'t Care?']]
        background              = workbook.row(row)[headers['Child\'s Background (Breif)']]
        able                    = workbook.row(row)[headers['ABLE']]
        exit_date               = workbook.row(row)[headers['Date Exit From Program']]
        initial_assessment_date = workbook.row(row)[headers['Date Initial Assessment']]
        case_conference_date    = workbook.row(row)[headers['Date Case Conference']]
        case_length             = workbook.row(row)[headers['Case Length']]

        ongoing_partner         = Partner.find_or_create_by(name: ongoing_partner_name)
        province_autocorrect    = ProvinceAutocorrect.new
        province                = Province.find_or_create_by(name: province_autocorrect.validate(province_name))
        family                  = Family.find_or_create_by(name: fc_family_info)
        staff                   = User.find_by(last_name: staff_name)
        creator                 = staff

        client = Client.find_or_initialize_by(first_name: name, date_of_birth: dob.try(:to_date), gender: gender)
        client.code                        = code
        client.has_been_in_orphanage       = word_to_boolean(has_been_in_orphanage)
        client.school_grade                = grade
        client.school_name                 = school
        client.status                      = 'Active FC'
        client.able                        = word_to_boolean(able)
        client.current_address             = village
        client.has_been_in_government_care = word_to_boolean(is_in_government_care)
        client.province_id                 = province.try(:id)
        client.user_id                     = creator.try(:id)
        client.state                       = 'accepted'
        client.background                  = background
        client.save

        fc = client.cases.create(
          placement_date: date_of_placement.try(:to_date),
          support_amount: support_amount,
          support_note: support_note,
          case_type: 'FC',
          status: status,
          exit_date: exit_date.try(:to_date),
          family_id: family.try(:id),
          user_id: creator.try(:id),
          partner_id: ongoing_partner.try(:id),
          province_id: province.try(:id),
          initial_assessment_date: initial_assessment_date,
          case_conference_date: case_conference_date,
          case_length: case_length,
          time_in_care: time_in_care,
        )

        if creator.nil?
          logger = Logger.new('log/import.log')
          logger.info "Create Client with user_id nil on client #{client.id}"
        end
      end
    end

    def partners
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        partner               = workbook.row(row)[headers['Partner']]
        province_name         = workbook.row(row)[headers['Province']]
        city_name             = workbook.row(row)[headers['City']]
        address               = workbook.row(row)[headers['Address']]
        contact_person_name   = workbook.row(row)[headers['Contact Person Name']]
        contact_person_email  = workbook.row(row)[headers['Contact Email']]
        contact_person_mobile = workbook.row(row)[headers['Contact Phone Number']]
        affiliation           = workbook.row(row)[headers['Affiliation']]
        type                  = workbook.row(row)[headers['Type']]
        engagement            = workbook.row(row)[headers['Engagement Info']]
        background            = workbook.row(row)[headers['Church Background']]
        start_date            = workbook.row(row)[headers['Church Start Date']]

        province_autocorrect = ProvinceAutocorrect.new
        province             = Province.find_or_create_by(name: province_autocorrect.validate(province_name))

        Partner.find_or_create_by(
          name: partner,
          address: [city_name, address].join(', '),
          contact_person_name: contact_person_name,
          contact_person_email: contact_person_email,
          contact_person_mobile: contact_person_mobile,
          affiliation: affiliation,
          engagement: engagement,
          background: background,
          start_date: start_date.try(:to_date),
          organisation_type: type,
          province_id: province.try(:id)
        )
      end
    end

    def quarterly_reports
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        visit_date                                               = workbook.row(row)[headers['Date of Visit']]
        code                                                     = workbook.row(row)[headers['ID']]
        kc_name                                                  = workbook.row(row)[headers['KC Name']]
        fc_name                                                  = workbook.row(row)[headers['FC Name']]
        general_health_or_appearance                             = workbook.row(row)[headers['Describe general Health/Appearance']]
        child_school_attendance_or_progress                      = workbook.row(row)[headers['What is the Child\'s school attendance/progress']]
        general_appearance_of_home                               = workbook.row(row)[headers['Describe General Appearance of Home']]
        observations_of_drug_alchohol_abuse                      = workbook.row(row)[headers['Describe any observations of drug, alchohol, abuse, etc.']]
        describe_if_yes                                          = workbook.row(row)[headers['If yes, desribe..']]
        describe_the_family_current_situation                    = workbook.row(row)[headers['Describe the family\'s current situation…']]
        has_the_situation_changed_from_the_previous_visit        = workbook.row(row)[headers['Has the situation changed from the previous visit?']]
        how_did_i_encourage_the_client                           = workbook.row(row)[headers['How did I encourage the client?']]
        what_future_teachings_or_trainings_could_help_the_client = workbook.row(row)[headers['What future teachings/trainings could help the client?']]
        what_is_my_plan_for_the_next_visit_to_the_client         = workbook.row(row)[headers['What is my plan for the next visit to the client?']]
        money_and_supplies_being_used_appropriately              = workbook.row(row)[headers['Money and supplies being used appropriately?']]
        how_are_they_being_misused                               = workbook.row(row)[headers['If no, how are they being misused?']]
        staff_information                                        = workbook.row(row)[headers['Staff Information']]
        spiritual_developments_with_the_child_or_family          = workbook.row(row)[headers['Any Spiritual developments with the child or family?']]

        staff = User.find_by(last_name: staff_information)

        client_code = kc_name.blank? ? fc_name : kc_name

        if !client_code.blank?
          client_code = client_code.split('-')[1].strip
          client_case = Client.find_by(code: client_code).cases.last
        end

        QuarterlyReport.create(
          visit_date: visit_date.try(:to_date),
          code: code,
          general_health_or_appearance: general_health_or_appearance,
          child_school_attendance_or_progress: child_school_attendance_or_progress,
          general_appearance_of_home: general_appearance_of_home,
          observations_of_drug_alchohol_abuse: observations_of_drug_alchohol_abuse,
          describe_if_yes: describe_if_yes,
          describe_the_family_current_situation: describe_the_family_current_situation,
          has_the_situation_changed_from_the_previous_visit: has_the_situation_changed_from_the_previous_visit,
          how_did_i_encourage_the_client: how_did_i_encourage_the_client,
          what_future_teachings_or_trainings_could_help_the_client: what_future_teachings_or_trainings_could_help_the_client,
          what_is_my_plan_for_the_next_visit_to_the_client: what_is_my_plan_for_the_next_visit_to_the_client,
          money_and_supplies_being_used_appropriately: word_to_boolean(money_and_supplies_being_used_appropriately),
          how_are_they_being_misused: how_are_they_being_misused,
          spiritual_developments_with_the_child_or_family: spiritual_developments_with_the_child_or_family,
          staff_id: staff.try(:id),
          case_id: client_case.try(:id)
        )
      end
    end

    def quantitatives
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        quantitative_type_name = workbook.row(row)[headers['Quantitative Type']]
        quantitative_data = workbook.row(row)[headers['Quantitative Data']]

        quantitative_type = QuantitativeType.create(name: quantitative_type_name)
        quantitative_data.split(';').each do |data|
          quantitative_type.quantitative_cases.create(value: data.strip)
        end
      end
    end

    protected

    def word_to_boolean(value)
      value.downcase! if value.present?

      value == 'yes'
    end
  end
end