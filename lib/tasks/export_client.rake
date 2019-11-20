namespace :export_client do
  desc "Export client to CSV"
  task birth_province: :environment do
    headers = ['org_name', 'client_id', 'Client name', 'province_id', 'Province name', 'district_id', 'District name', 'commune_id', 'Commune name', 'village_id', 'Village name']
    row_index = 0
    workbook = WriteXLSX.new("#{Rails.root}/clients-birth-province-#{Date.today}.xlsx")
    worksheet = workbook.add_worksheet
    format = workbook.add_format
    format.set_align('center')

    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name

      if row_index == 0
        headers.each_with_index do |header, header_index|
          worksheet.write(0, header_index, header, format)
        end
      end

      Client.all.each do |client|
        province_id = client.province_id
        next if client.district_id.nil? || client.province_id == client.district.province_id
        province = Province.find(client.district.province_id)
        columns = [
                short_name, client.id, client.en_and_local_name, client.province_id,
                client.province.name, client.district_id, "#{client.district.name} (#{province.name})",
                client.commune_id, client.commune.try(:name), client.village_id, client.village.try(:name)
              ]

        row_index += 1
        columns.each_with_index do |column, column_index|
          worksheet.write(row_index, column_index, column, format)
        end
      end
    end
    workbook.close
  end

  task dob: :environment do
    headers = ['org_name', 'client_id', 'Client name', 'Date of birth', 'age (Years)']
    row_index = 0
    workbook = WriteXLSX.new("#{Rails.root}/clients-dob-#{Date.today}.xlsx")
    worksheet = workbook.add_worksheet
    format = workbook.add_format
    format.set_align('center')
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name

      if row_index == 0
        headers.each_with_index do |header, header_index|
          worksheet.write(0, header_index, header, format)
        end
      end

      Client.all.each do |client|
        next if (client.date_of_birth.present? && (client.age_as_years <= 18 && client.date_of_birth <= Date.today)) || client.date_of_birth.nil?

        dob = client.date_of_birth
        age = client.count_year_from_date('date_of_birth')

        columns = [short_name, client.id, client.en_and_local_name, dob, age]

        row_index += 1
        columns.each_with_index do |column, column_index|
          worksheet.write(row_index, column_index, column, format)
        end
      end
    end
    workbook.close
  end

  task exit_ngo: :environment do
    headers = ['org_name', 'client_id', 'Client name', 'status', 'Date of exit log', 'Reasons & Exit NGO date']
    row_index = 0
    workbook = WriteXLSX.new("#{Rails.root}/clients-exit-date-#{Date.today}.xlsx")
    worksheet = workbook.add_worksheet
    format = workbook.add_format
    format.set_align('center')
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name

      if row_index == 0
        headers.each_with_index do |header, header_index|
          worksheet.write(0, header_index, header, format)
        end
      end

      Client.where(status: 'Exited', exit_date: nil).each do |client|
        versions = client.versions.reject{ |version| !version.changeset.has_key?(:status) }
        changeset = versions.map do |version|
          next if version.changeset.dig('status').exclude?('Exited')
          version.changeset
        end

        next if changeset.compact.blank?

        reasons = client.exit_ngos.pluck(:exit_circumstance, :other_info_of_exit, :exit_note, :exit_date)

        exited_statuses = changeset.compact.last['status']
        exited_dates = changeset.compact.last['updated_at']

        found_index = changeset.compact.last['status'].find_index('Exited')
        exited_status = exited_statuses[found_index]
        exited_date = exited_dates[found_index]

        columns = [short_name, client.id, client.en_and_local_name, exited_status, changeset.to_s.to_date.to_s, reasons.join(', ')]
        row_index += 1
        columns.each_with_index do |column, column_index|
          worksheet.write(row_index, column_index, column, format)
        end
      end
    end
    workbook.close
  end

  task enter_ngo: :environment do
    headers = ['org_name', 'client_id', 'Client name', 'status', 'Date of accepting log', 'Enter NGO Date']
    row_index = 0
    workbook = WriteXLSX.new("#{Rails.root}/clients-accepted-date-#{Date.today}.xlsx")
    worksheet = workbook.add_worksheet
    format = workbook.add_format
    format.set_align('center')
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name

      if row_index == 0
        headers.each_with_index do |header, header_index|
          worksheet.write(0, header_index, header, format)
        end
      end

      Client.where(status: 'Accepted', accepted_date: nil).each do |client|
        versions = client.versions.reject{ |version| !version.changeset.has_key?(:status) }
        changeset = versions.map do |version|
          next if version.changeset.dig('status').exclude?('Accepted')
          version.changeset
        end

        next if changeset.compact.blank?

        reasons = client.enter_ngos.pluck(:accepted_date)

        accepted_statuses = changeset.compact.last['status']
        accepted_dates = changeset.compact.last['updated_at']

        found_index = changeset.compact.last['status'].find_index('Accepted')
        accepted_status = accepted_statuses[found_index]
        accepted_date = accepted_dates[found_index]

        columns = [short_name, client.id, client.en_and_local_name, accepted_status, changeset.to_s.to_date.to_s, reasons.join(', ')]
        row_index += 1
        columns.each_with_index do |column, column_index|
          worksheet.write(row_index, column_index, column, format)
        end
      end
    end
    workbook.close
  end

  task invalid_date: :environment do
    headers = ['org_name', 'client_id', 'Client name', 'follow_up_date', 'initial_referral_date', 'enrollment_date', 'meeting_date']
    row_index = 0
    workbook = WriteXLSX.new("#{Rails.root}/clients-invalid-date-#{Date.today}.xlsx")
    worksheet = workbook.add_worksheet
    format = workbook.add_format
    format.set_align('center')

    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name

      if row_index == 0
        headers.each_with_index do |header, header_index|
          worksheet.write(0, header_index, header, format)
        end
      end

      Client.all.each do |client|
        date_today = Date.today
        follow_up_date = client.count_year_from_date('follow_up_date')
        initial_referral_date = client.count_year_from_date('initial_referral_date')
        enrollment_dates = client.client_enrollments.where("client_enrollments.enrollment_date IS NOT NULL AND (EXTRACT(year FROM age(current_date, client_enrollments.enrollment_date)) :: int) >= ?", 120).pluck(:enrollment_date)
        meeting_dates = client.case_notes.where("case_notes.meeting_date IS NOT NULL AND (EXTRACT(year FROM age(current_date, case_notes.meeting_date)) :: int) >= ?", 120).pluck(:meeting_date)
        if follow_up_date.to_i >= 120 || initial_referral_date.to_i >= 120 || enrollment_dates.present? || meeting_dates.present?

          columns = [short_name, client.id, client.en_and_local_name, client.follow_up_date, client.initial_referral_date, enrollment_dates.join(', '), meeting_dates.join(', ')]

          row_index += 1
          columns.each_with_index do |column, column_index|
            worksheet.write(row_index, column_index, column, format)
          end
        end
      end
    end
    workbook.close
  end
end

