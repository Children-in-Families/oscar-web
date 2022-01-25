namespace :report_for_save do
  desc "Generate report for save"
  task :generate, [:global_id] => :environment do |task, args|
    sql = <<-SQL.squish
      SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
      INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
      INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
      WHERE "public"."donors"."global_id" = '#{args.global_id}'
    SQL
    organizations = ActiveRecord::Base.connection.execute(sql)

    domain_score_headers = ['1A', '1B', '2A', '2B',	'3A',	'3B',	'4A',	'4B',	'5A',	'5B',	'6A',	'6B']
    headers = [
      'Nº', 'Client ID', 'Status', 	'Gender',	'Date of birth',
      'Birth province',	'Current province',	'Family ID',	'NGO Name',
      'Initial referral date',	'NGO accepted date',	'NGO exited date',
      "History of disability and/or illness",	'History of Harm',	"History of high-risk behaviours",
      'Reason for Family Seperation',
      'Initial date of CSI', *domain_score_headers,
      'Latet date of CSI', *domain_score_headers,
      'Referral Source Category', 'Referral Source'
    ]

    cps_headers = ['Client ID',	'NGO Name',	'CPS Name', 'CPS erollment date',	'Service types', 'CPS exited date']

    workbook = WriteXLSX.new("#{Rails.root}/clients-end-line-data-#{Date.today}.xlsx")
    client_worksheet = workbook.add_worksheet('Clients')
    cps_worksheet = workbook.add_worksheet("Clients' Program Stream")
    format = workbook.add_format
    format.set_align('center')

    clients_data = []
    cps_enrollments = []
    organizations.each_with_index do |organization, index|
      Apartment::Tenant.switch organization['short_name']
      donor_ids = Donor.where("LOWER(donors.name) = 'fcf' OR LOWER(donors.name) = 'react'").ids
      clients = Client.joins(:donors).where(donor_id: donor_ids)

      quantitative_type_disability = QuantitativeType.pluck(:name).select{|custom_data| custom_data[/Family history of disability and\/or illness/i] }.first
      quantitative_type_harm = QuantitativeType.pluck(:name).select{|custom_data| custom_data[/History of Harm/i] }.first
      quantitative_type_behaviour = QuantitativeType.pluck(:name).select{|custom_data| custom_data[/History of high-risk behaviours/i] }.first
      quantitative_type_separation = QuantitativeType.pluck(:name).select{|custom_data| custom_data[/Reason for Family Separation/i] }.first

      clients.each do |client|
        default_assessments = client.assessments.defaults
        qtypes = client.quantitative_cases.group_by(&:quantitative_type).map{|quantitative, quantitative_cases| [quantitative.name, quantitative_cases.map(&:value).join(', ')] }.to_h

        Apartment::Tenant.switch 'shared'
        birth_province = client.birth_province && client.birth_province.name
        Apartment::Tenant.switch organization['short_name']

        values = [
          index = index + 1,
          client.slug, client.status, client.gender.capitalize,
          client.date_of_birth && format_date(client.date_of_birth),
          birth_province,
          client.province.name,
          client.current_family_id,
          "#{organization['full_name']} (#{organization['short_name']})",
          format_date(client.initial_referral_date),
          format_date(client.accepted_date),
          format_date(client.exit_date),
          qtypes[quantitative_type_disability],
          qtypes[quantitative_type_harm],
          qtypes[quantitative_type_behaviour],
          qtypes[quantitative_type_separation],
          format_date(default_assessments.first.created_at),
          *default_assessments.first.domains.pluck(:name, :score).map { |item| item.join(': ') },
          default_assessments.count > 1 && format_date(client.assessments.last.created_at),
          *default_assessments.last.domains.pluck(:name, :score).map { |item| item.join(': ') },
          referral_source_category(client.referral_source_category_id),
          client.referral_source && client.referral_source.name
        ]
        clients_data << values

        client.client_enrollments.each do |client_enrollment|
          cps_enrollments << [client.slug, "#{organization['full_name']} (#{organization['short_name']})", client_enrollment.program_stream.name, format_date(client_enrollment.enrollment_date), client_enrollment.program_stream.services.distinct.map(&:name).join(', '), format_date(client_enrollment.leave_program && client_enrollment.leave_program.exit_date)]
        end
      end
    end

    write_data_to_spreadsheet(client_worksheet, headers, clients_data, format)
    write_data_to_spreadsheet(cps_worksheet, cps_headers, cps_enrollments, format)

    workbook.close
  end

  def format_date(date)
    return '' if date.blank?
    date.strftime('%d %B %Y')
  end

  def referral_source_category(id)
    ReferralSource.find_by(id: id).try(:name_en) || ReferralSource.find_by(id: id).try(:name)
  end

  def write_data_to_spreadsheet(worksheet, headers, values, format)
    return if values.first.compact.blank?
    headers.each_with_index do |header, header_index|
      worksheet.write(0, header_index, header, format)
    end

    values.each_with_index do |data_hash, row_index|
      data_hash.each_with_index do |column, column_index|
        worksheet.write(row_index + 1, column_index, column, format)
      end
    end
  end

end
