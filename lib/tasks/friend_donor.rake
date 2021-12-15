namespace :friend_donor do
  desc "Generate report for Save the Children"
  task report: :environment do
    sql = <<-SQL.squish
      SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
      INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
      INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
      WHERE "public"."donors"."global_id" = ''
    SQL
    organizations = ActiveRecord::Base.connection.execute(sql)
    organization_client_sql = organizations.map do |organization|
      donor_sql = map_donor_sql(organization)
      <<-SQL.squish
        SELECT clients.id, clients.slug, '#{organization['short_name']}' organization_name, clients.gender, clients.donor_id, clients.exit_date, clients.accepted_date,
        clients.date_of_birth, clients.status, clients.province_id, provinces.name as current_province,
        clients.birth_province_id, clients.follow_up_date,
        clients.initial_referral_date, clients.referral_source_category_id, clients.created_at,
        clients.updated_at FROM #{organization['short_name']}.clients INNER JOIN #{organization['short_name']}.sponsors ON #{organization['short_name']}.sponsors.client_id = #{organization['short_name']}.clients.id INNER JOIN #{organization['short_name']}.donors ON #{organization['short_name']}.donors.id = #{organization['short_name']}.sponsors.donor_id
        LEFT OUTER JOIN #{organization['short_name']}.provinces ON #{organization['short_name']}.provinces.id = #{organization['short_name']}.clients.province_id
        WHERE #{organization['short_name']}.sponsors.donor_id
        IN (#{donor_sql})
      SQL
    end.join(' UNION ')

    clients = ActiveRecord::Base.connection.execute(organization_client_sql)

    data = clients.to_a
    workbook = WriteXLSX.new("#{Rails.root}/clients-#{Date.today}.xlsx")
    client_worksheet = workbook.add_worksheet('Clients')
    format = workbook.add_format
    format.set_align('center')

    write_data_to_spreadsheet(client_worksheet, data, format)

    case_note_worksheet =  workbook.add_worksheet('Case notes')
    organization_case_note_sql = organizations.map do |organization|
      donor_sql = map_donor_sql(organization)
      <<-SQL.squish
        SELECT case_notes.id, '#{organization['short_name']}' organization_name, case_notes.client_id, case_notes.meeting_date FROM #{organization['short_name']}.case_notes
        INNER JOIN #{organization['short_name']}.clients ON #{organization['short_name']}.clients.id = #{organization['short_name']}.case_notes.client_id
        INNER JOIN #{organization['short_name']}.sponsors ON #{organization['short_name']}.sponsors.client_id = #{organization['short_name']}.clients.id
        INNER JOIN #{organization['short_name']}.donors ON #{organization['short_name']}.donors.id = #{organization['short_name']}.sponsors.donor_id
        WHERE #{organization['short_name']}.sponsors.donor_id IN (#{donor_sql})
      SQL
    end.join(' UNION ')
    case_notes = ActiveRecord::Base.connection.execute(organization_case_note_sql)
    write_data_to_spreadsheet(case_note_worksheet, case_notes.to_a, format)

    client_program_stream_worksheet = workbook.add_worksheet('Client Program Streams')
    client_program_stream_sql = organizations.map do |organization|
      donor_sql = map_donor_sql(organization)
      <<-SQL
        SELECT client_enrollments.id, '#{organization['short_name']}' organization_name, client_enrollments.client_id, client_enrollments.program_stream_id,
        client_enrollments.status, client_enrollments.enrollment_date, client_enrollments.created_at, client_enrollments.updated_at FROM #{organization['short_name']}.client_enrollments
        INNER JOIN #{organization['short_name']}.clients ON #{organization['short_name']}.clients.id = #{organization['short_name']}.client_enrollments.client_id
        INNER JOIN #{organization['short_name']}.sponsors ON #{organization['short_name']}.sponsors.client_id = #{organization['short_name']}.clients.id
        INNER JOIN #{organization['short_name']}.donors ON #{organization['short_name']}.donors.id = #{organization['short_name']}.sponsors.donor_id
        WHERE #{organization['short_name']}.client_enrollments.deleted_at IS NULL AND #{organization['short_name']}.sponsors.donor_id IN (#{donor_sql})
      SQL
    end.join(' UNION ')
    client_program_streams = ActiveRecord::Base.connection.execute(client_program_stream_sql)
    write_data_to_spreadsheet(client_program_stream_worksheet, client_program_streams.to_a, format)

    program_stream_worksheet = workbook.add_worksheet('Program Streams')
    program_stream_sql = organizations.map do |organization|
      <<-SQL
        SELECT program_streams.id, '#{organization['short_name']}' organization_name, program_streams.name, program_streams.ngo_name,
        program_streams.completed, program_streams.enrollment, program_streams.description FROM #{organization['short_name']}.program_streams
      SQL
    end.join(' UNION ')
    program_streams = ActiveRecord::Base.connection.execute(program_stream_sql)
    write_data_to_spreadsheet(program_stream_worksheet, program_streams.to_a, format)

    enter_ngo_worksheet = workbook.add_worksheet('Enter NGO (NGO Accepted)')
    enter_ngo_sql = organizations.map do |organization|
      donor_sql = map_donor_sql(organization)
      <<-SQL
        SELECT enter_ngos.id, '#{organization['short_name']}' organization_name, enter_ngos.client_id,
        enter_ngos.accepted_date, enter_ngos.created_at, enter_ngos.updated_at FROM #{organization['short_name']}.enter_ngos
        INNER JOIN #{organization['short_name']}.clients ON #{organization['short_name']}.clients.id = #{organization['short_name']}.enter_ngos.client_id
        INNER JOIN #{organization['short_name']}.sponsors ON #{organization['short_name']}.sponsors.client_id = #{organization['short_name']}.clients.id
        INNER JOIN #{organization['short_name']}.donors ON #{organization['short_name']}.donors.id = #{organization['short_name']}.sponsors.donor_id
        WHERE #{organization['short_name']}.enter_ngos.deleted_at IS NULL AND #{organization['short_name']}.sponsors.donor_id IN (#{donor_sql})
      SQL
    end.join(' UNION ')
    enter_ngos = ActiveRecord::Base.connection.execute(enter_ngo_sql)
    write_data_to_spreadsheet(enter_ngo_worksheet, enter_ngos.to_a, format)

    exit_ngo_worksheet = workbook.add_worksheet('Exit NGO (NGO Exited)')
    exit_ngo_sql = organizations.map do |organization|
      donor_sql = map_donor_sql(organization)
      <<-SQL
        SELECT exit_ngos.id, '#{organization['short_name']}' organization_name, exit_ngos.client_id,
        exit_ngos.exit_reasons, exit_ngos.exit_circumstance, exit_ngos.exit_date, exit_ngos.created_at, exit_ngos.updated_at
        FROM #{organization['short_name']}.exit_ngos INNER JOIN #{organization['short_name']}.clients ON #{organization['short_name']}.clients.id = #{organization['short_name']}.exit_ngos.client_id
        INNER JOIN #{organization['short_name']}.sponsors ON #{organization['short_name']}.sponsors.client_id = #{organization['short_name']}.clients.id
        INNER JOIN #{organization['short_name']}.donors ON #{organization['short_name']}.donors.id = #{organization['short_name']}.sponsors.donor_id
        WHERE #{organization['short_name']}.exit_ngos.deleted_at IS NULL AND #{organization['short_name']}.sponsors.donor_id IN (#{donor_sql})
      SQL
    end.join(' UNION ')
    exit_ngos = ActiveRecord::Base.connection.execute(exit_ngo_sql)
    write_data_to_spreadsheet(exit_ngo_worksheet, exit_ngos.to_a, format)

    assessment_worksheet = workbook.add_worksheet('Assessment')
    assessment_sql = organizations.map do |organization|
      donor_sql = map_donor_sql(organization)
      <<-SQL
        SELECT assessments.id, '#{organization['short_name']}' organization_name, assessments.client_id,
        assessments.completed, assessments.default as default_assessment, assessments.created_at FROM #{organization['short_name']}.assessments
        INNER JOIN #{organization['short_name']}.clients ON #{organization['short_name']}.clients.id = #{organization['short_name']}.assessments.client_id
        INNER JOIN #{organization['short_name']}.sponsors ON #{organization['short_name']}.sponsors.client_id = #{organization['short_name']}.clients.id
        INNER JOIN #{organization['short_name']}.donors ON #{organization['short_name']}.donors.id = #{organization['short_name']}.sponsors.donor_id
        WHERE #{organization['short_name']}.sponsors.donor_id IN (#{donor_sql})
      SQL
    end.join(' UNION ')
    assessments = ActiveRecord::Base.connection.execute(assessment_sql)
    write_data_to_spreadsheet(assessment_worksheet, assessments.to_a, format)

    assessment_domain_worksheet = workbook.add_worksheet('Assessment Domain')
    assessment_domain_sql = organizations.map do |organization|
      <<-SQL
        SELECT assessment_domains.id, '#{organization['short_name']}' organization_name, assessment_domains.domain_id, assessment_domains.assessment_id, assessment_domains.score FROM #{organization['short_name']}.assessment_domains
      SQL
    end.join(' UNION ')
    assessment_domains = ActiveRecord::Base.connection.execute(assessment_domain_sql)
    write_data_to_spreadsheet(assessment_domain_worksheet, assessment_domains.to_a, format)

    domain_worksheet = workbook.add_worksheet('Domains')
    domain_sql = organizations.map do |organization|
      <<-SQL
        SELECT domains.id, '#{organization['short_name']}' organization_name,
        domains.name, domains.identity, domains.description, domains.domain_group_id, domains.score_1_color,
        domains.score_2_color, domains.score_3_color, domains.score_4_color, domains.score_1_definition,
        domains.score_2_definition, domains.score_3_definition, domains.score_4_definition,
        domains.local_description, domains.score_1_local_definition, domains.score_2_local_definition,
        domains.score_3_local_definition, domains.score_4_local_definition, domains.custom_domain
        FROM #{organization['short_name']}.domains
      SQL
    end.join(' UNION ')
    domains = ActiveRecord::Base.connection.execute(domain_sql)
    write_data_to_spreadsheet(domain_worksheet, domains.to_a, format)

    workbook.close
  end

  # =========================================================
  def map_donor_sql(organization)
    "SELECT #{organization['short_name']}.donors.id FROM donors WHERE LOWER(#{organization['short_name']}.donors.name) = 'fcf' OR LOWER(#{organization['short_name']}.donors.name) = 'react'"
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
