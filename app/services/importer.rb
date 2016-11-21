module Importer
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/clients_to_demo.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)
      # @workbook = Roo::CSV.new(path)

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

    def clients
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        users            = User.order(:id)
        families         = Family.order(:id)
        referral_sources = ReferralSource.order(:id)
        provinces        = Province.order(:id)
        partners         = Partner.order(:id)

        user_id            = rand(users.first.id..users.last.id)
        family_id          = rand(families.first.id..families.last.id)
        referral_source_id = rand(referral_sources.first.id..referral_sources.last.id)
        provine_id         = rand(provinces.first.id..provinces.last.id)
        partner_id         = rand(partners.first.id..partners.last.id)

        code       = workbook.row(row)[headers['Code']]
        first_name = workbook.row(row)[headers['Name']]
        gender     = workbook.row(row)[headers['Gender']]
        status     = workbook.row(row)[headers['Status']]
        follow_up_date        = workbook.row(row)[headers['Follow Up Date']]
        current_address       = workbook.row(row)[headers['Current Address']]
        school_name           = workbook.row(row)[headers['School Name']]
        school_grade          = workbook.row(row)[headers['School Grade']]
        date_of_birth         = workbook.row(row)[headers['Date of Birth']]
        initial_referral_date = workbook.row(row)[headers['Initial Referral Date']]
        relevant_referral_information = workbook.row(row)[headers['Relevant Referral Information']]
        referral_phone        = workbook.row(row)[headers['Referral Phone']]
        able_state            = workbook.row(row)[headers['Able State']]
        state                 = workbook.row(row)[headers['Accept/Reject']] || ''
        rejected_note         = workbook.row(row)[headers['Rejected Note']]

        c = Client.new(
          code: code,
          first_name: first_name,
          gender: gender.downcase,
          status: status,
          follow_up_date: follow_up_date,
          received_by_id: user_id,
          followed_up_by_id: user_id,
          date_of_birth: date_of_birth,
          current_address: current_address,
          school_name: school_name,
          school_grade: school_grade,
          initial_referral_date: initial_referral_date,
          relevant_referral_information: relevant_referral_information,
          referral_phone: referral_phone,
          referral_source_id: referral_source_id,
          able_state: able_state,
          birth_province_id: provine_id,
          province_id: provine_id,
          state: state.downcase,
          rejected_note: rejected_note,
          user_id: user_id
        )
        c.save

        if c.status == 'Active EC'
          Case.create(client_id: c.id, case_type: 'EC', start_date: Date.today, family_id: family_id, user_id: c.user_id, partner_id: partner_id)
        elsif c.status == 'Active FC'
          Case.create(client_id: c.id, case_type: 'FC', start_date: Date.today, family_id: family_id, user_id: c.user_id, partner_id: partner_id)
        elsif c.status == 'Active KC'
          Case.create(client_id: c.id, case_type: 'KC', start_date: Date.today, family_id: family_id, user_id: c.user_id, partner_id: partner_id)
        end
      end
    end

    # def agencies
    #   ((workbook.first_row + 1)..workbook.last_row).each do |row|
    #     name = workbook.row(row)[headers['Name']]
    #     Agency.create(
    #       name: name
    #     )
    #   end
    # end

    # def departments
    #   ((workbook.first_row + 1)..workbook.last_row).each do |row|
    #     name = workbook.row(row)[headers['Name']]

    #     Department.create(
    #       name: name
    #     )
    #   end
    # end

    # def provinces
    #   ((workbook.first_row + 1)..workbook.last_row).each do |row|
    #     name = workbook.row(row)[headers['Name']]

    #     Province.create(
    #       name: name
    #     )
    #   end
    # end

    # def referral_sources
    #   ((workbook.first_row + 1)..workbook.last_row).each do |row|
    #     name = workbook.row(row)[headers['Name']]

    #     ReferralSource.create(
    #       name: name
    #     )
    #   end
    # end

    # def quantitative_types
    #   ((workbook.first_row + 1)..workbook.last_row).each do |row|
    #     name = workbook.row(row)[headers['Name']]

    #     QuantitativeType.create(
    #       name: name
    #     )
    #   end
    # end

    # def quantitative_cases
    #   ((workbook.first_row + 1)..workbook.last_row).each do |row|
    #     value   = workbook.row(row)[headers['Name']]
    #     type    = workbook.row(row)[headers['Type']]
    #     type_id = QuantitativeType.find_by(name: type).id

    #     QuantitativeCase.create(
    #       value: value,
    #       quantitative_type_id: type_id
    #     )
    #   end
    # end
  end
end
