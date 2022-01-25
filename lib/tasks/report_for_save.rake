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
    headers = ['Client ID',
      'Status',
      'Gender',
      'Current Address – Province',
      'Date of birth',
      'Birth province',
      'CSI assessment initial date',
      'CSI assessment latest date',
      'CSI initial assessment\'s scores',
      'CSI last assessment\'s scores',
      'Custom Referral Data',
      'Family ID',
      'Initial referral date',
      'NGO accepted date',
      'NGO name',
      'CPS name',
      'CPS enrollment date',
      'Service type',
      'NGO exited date',
      'Referral source category',
      'Referral source']

    workbook = WriteXLSX.new("#{Rails.root}/clients-end-line-data-#{Date.today}.xlsx")
    client_worksheet = workbook.add_worksheet('Clients')
    format = workbook.add_format
    format.set_align('center')

    organization_client_sql = organizations.map do |organization|
      Apartment::Tenant.switch organization['short_name']
      donor_ids = Donor.where("LOWER(donors.name) = 'fcf' OR LOWER(donors.name) = 'react'").ids
      clients = Client.joins(:donors).where(donor_id: donor_ids)

      values = clients.map do |client|
        default_assessments = client.assessments.defaults
        qtypes = client.quantitative_cases.group_by(&:quantitative_type)
        [
          client.slug, client.status, client.gender.capitalize,
          client.province.name, client.date_of_birth && format_date(client.date_of_birth),
          client.birth_province && client.birth_province.name,
          format_date(default_assessments.first.created_at),
          default_assessments.count > 1 && format_date(client.assessments.last.created_at),
          default_assessments.first.domains.pluck(:name, :score).map { |item| item.join(': ') }.join(', '),
          default_assessments.last.domains.pluck(:name, :score).map { |item| item.join(': ') }.join(', '),
          *qtypes.map{|qtype| qtype.last.map(&:value).join(', ') },
          client.current_family_id,
          format_date(client.accepted_date),
          "#{organization['full_name']}(#{organization['short_name']})",
          client.program_streams.pluck(:name).join(', '),
          client.client_enrollments.map{|client_enrollment| format_date(client_enrollment.enrollment_date) }.join(', '),
          client.program_streams.map{|program_stream| "#{program_stream.name} => (#{program_stream.services.map(&:name).join(', ')})" }.join(', '),
          format_date(client.exit_ngos.last.exit_date),
          referral_source_category(client.referral_source_category_id),
          client.referral_source && client.referral_source.name
        ]
      end

      binding.pry

    end

    service_worksheet = workbook.add_worksheet('Services')
    service_sql = organizations.map do |organization|
      <<-SQL
        SELECT services.id, '#{organization['short_name']}' organization_name, services.name, services.parent_id FROM #{organization['short_name']}.services
      SQL
    end.join(' UNION ')
    services = ActiveRecord::Base.connection.execute(service_sql)
    write_data_to_spreadsheet(service_worksheet, services.to_a, format)

    workbook.close
  end

  def format_date(date)
    date.strftime('%d %B %Y')
  end

  def referral_source_category(id)
    ReferralSource.find_by(id: id).try(:name_en) || ReferralSource.find_by(id: id).try(:name)
  end

  def write_data_to_spreadsheet(worksheet, data, format)
    return if data.first.nil?
    data.first.keys.each_with_index do |header, header_index|
      worksheet.write(0, header_index, header, format)
    end

    data.each_with_index do |data_hash, row_index|
      data_hash.values.each_with_index do |column, column_index|
        worksheet.write(row_index + 1, column_index, column, format)
      end
    end
  end

end
