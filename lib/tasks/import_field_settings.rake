namespace :field_settings do
  desc 'Import default field settings data'
  task :import, [:short_name] => :environment do |task, args|
    workbook = Roo::Excelx.new('db/support/field_settings.xlsx')
    headers = {}

    organisations = Organization.where.not(short_name: 'shared')
    organisations = organisations.where(short_name: args.short_name) if args && args.short_name.present?

    organisations.find_each do |org|
      Organization.switch_to org.short_name
      sheet = workbook.sheet(0)
      sheet = workbook.sheet(1) if org.short_name == 'brc'

      sheet.row(1).each_with_index { |header, i| headers[header] = i }

      (2..sheet.last_row).each do |row_index|
        # In case sheet is messed up
        next if sheet.row(row_index)[headers['name']].blank?

        field_setting = FieldSetting.find_or_initialize_by(name: sheet.row(row_index)[headers['name']], klass_name: sheet.row(row_index)[headers['klass_name']])
        field_setting.update!(
          label: sheet.row(row_index)[headers['label']] || sheet.row(row_index)[headers['current_label']],
          type: sheet.row(row_index)[headers['type']],
          current_label: sheet.row(row_index)[headers['current_label']],
          klass_name: sheet.row(row_index)[headers['klass_name']],
          required: sheet.row(row_index)[headers['required']].to_i,
          visible: sheet.row(row_index)[headers['visible']].to_i,
          for_instances: workbook.row(row_index)[headers['for_instances']],
          group: sheet.row(row_index)[headers['group']]
        )
      end

      create_government_form_setting
      create_assessment_setting
      create_legal_doc_settting

      [20200707042500, 20200710033402, 20220523095812, 20200710122049, 20200713035828, 20200714092201, 20200810055448, 20200810070640].each do |migration_version|
        ActiveRecord::Migrator.run(:down, ActiveRecord::Migrator.migrations_path, migration_version)
        ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_path, migration_version)
      end

      family_address_setting(org)

      # Introducing form_group_1
      ActiveRecord::Migrator.run(:down, ActiveRecord::Migrator.migrations_path, 20230717162200)
      ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_path, 20230717162200)
    end
  end

  private

  def create_government_form_setting
    field_setting = FieldSetting.find_or_initialize_by(name: :government_forms)
    field_setting.update!(
      label: 'Government Forms',
      current_label: 'Government Forms',
      klass_name: :client,
      required: false,
      visible: %w(brc ratanak).exclude?(Apartment::Tenant.current_tenant),
      group: :client
    )
  end

  def create_assessment_setting
    field_setting = FieldSetting.find_or_initialize_by(name: :reason)
    field_setting.update!(
      current_label: 'Observation',
      klass_name: :assessment,
      required: true,
      visible: true,
      group: :assessment
    )

    field_setting.update!(label: 'Review current need') if Apartment::Tenant.current_tenant == 'ratanak'
  end

  def create_legal_doc_settting
    fields = {
      :national_id => 'National ID',
      :birth_cert => 'Birth Certificate',
      :family_book => 'Family Book',
      :passport => 'Passport',
      :travel_doc => 'Temporary Travel Document',
      :referral_doc => 'Referral Documents',
      :local_consent => 'Legal consent',
      :police_interview => 'Police interview',
      :other_legal_doc => 'Others'
    }

    if Apartment::Tenant.current_tenant == 'ratanak'
      fields = fields.merge(
        :legal_documents => 'Referral Source Documents',
        :travel_doc => 'Laissez-Passer',
        :referral_doc => 'Screening Interview Form',
        :local_consent => 'Legal Representation',
        :police_interview => 'Letter from Immigration Police',
      )
    end

    fields.each do |name, label|
      field_setting = FieldSetting.find_or_initialize_by(name: name, klass_name: :client)
      field_setting.update!(
        current_label: label,
        label: label,
        required: false,
        visible: (Apartment::Tenant.current_tenant == 'ratanak'),
        group: :client
      )
    end
  end

  def family_address_setting(org)
    fields = {
      current_province: 'Current Department',
      birth_province: 'Birth Department',
      province: 'Department',
      district: 'Arrondissement',
      commune: 'Commune'
    }

    field_ids = {
      province_id: 'Department',
      district_id: 'Arrondissement',
      commune_id: 'Commune'
    }

    if org.country == 'haiti'
      concern_fields = {
        concern_province_id: 'Department',
        concern_district_id: 'Arrondissement',
        concern_commune_id: 'Commune',
      }
      fields.merge(concern_fields).each do |name, label|
        field_setting = FieldSetting.find_or_initialize_by(name: name, klass_name: :client)
        field_setting.update!(
          current_label: label,
          label: label,
          required: false,
          visible: (org.country == 'haiti'),
          group: :client
        )
      end

      field_ids.each do |name, label|
        field_setting = FieldSetting.find_or_initialize_by(name: name, klass_name: :family)
        field_setting.update!(
          current_label: label,
          label: label,
          required: false,
          visible: (org.country == 'haiti'),
          group: :family
        )
      end

      ['user', 'partner'].each do |klass_name|
        field_setting = FieldSetting.find_or_initialize_by(name: 'province', klass_name: klass_name)
        field_setting.update!(
          current_label: 'Department',
          label: 'Department',
          required: false,
          visible: (org.country == 'haiti'),
          group: klass_name
        )
      end
    end
  end
end
