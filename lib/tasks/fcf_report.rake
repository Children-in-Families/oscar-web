namespace :fcf_report do
  desc "Generate report for FCF"
  task generate: :environment do
    headers = ['Client ID',	'Case Created Date',	'NGO Name',	'Initial Referral Date',	'Referral Source Category',	'Referral Source',	'Status']

    workbook = WriteXLSX.new("#{Rails.root}/clients-data-#{Date.today}.xlsx")
    format = workbook.add_format
    format.set_align('center')

    ['2021-12-01', '2022-01-01', '2022-02-01'].each do |date|
      clients_data = []
      sheet_name = Date.parse(date).to_formatted_s(:long)
      worksheet = workbook.add_worksheet(sheet_name)

      Organization.visible.oscar.pluck(:short_name, :full_name).each do |short_name, full_name|
        Apartment::Tenant.switch short_name
        Client.joins("INNER JOIN referral_sources ON clients.referral_source_category_id = referral_sources.id").where(created_at: [date..Date.parse(date).end_of_month.to_s]).each do |client|
          clients_data << [
            client.slug,
            client.created_at.to_formatted_s(:long),
            "#{full_name}(#{short_name})",
            client.initial_referral_date.to_formatted_s(:long),
            ReferralSource.find_by(id: client.referral_source_category_id).try(:name),
            client.referral_source_name,
            client.status
          ]
        end
      end

      write_data_to_spreadsheet2(worksheet, headers, clients_data, format)
    end

    workbook.close
  end
end
