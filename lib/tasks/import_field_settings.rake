namespace :field_settings do
  desc 'Import default field settings data'
  task import: :environment do
    workbook = Roo::Excelx.new('db/support/field_settings.xlsx')
    headers = {}

    Organization.find_each do |org|
      Organization.switch_to org.short_name

      sheet = workbook.sheet(0)
      sheet = workbook.sheet(1) if org.short_name.in?(['dev', 'brc'])
      sheet.row(1).each_with_index { |header, i| headers[header] = i }

      (2..sheet.last_row).each do |row_index|
        # In case sheet is messed up
        next if sheet.row(row_index)[headers['name']].blank?

        field_setting = FieldSetting.find_or_initialize_by(name: sheet.row(row_index)[headers['name']])

        field_setting.update!(
          label: sheet.row(row_index)[headers['label']],
          type: sheet.row(row_index)[headers['type']],
          current_label: sheet.row(row_index)[headers['current_label']],
          klass_name: sheet.row(row_index)[headers['klass_name']],
          required: sheet.row(row_index)[headers['required']].to_i,
          visible: sheet.row(row_index)[headers['visible']].to_i,
          group: sheet.row(row_index)[headers['group']]
        )
      end
    end
  end
end
