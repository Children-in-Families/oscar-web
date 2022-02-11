namespace :active_client_in_kc_fc do
  desc "Generate active clients who been enrolled in Kinship Care and Foster Care"
  task generate: :environment do
    workbook = WriteXLSX.new("#{Rails.root}/active-clients-in-kc-fc-#{Date.today}.xlsx")
    format = workbook.add_format
    format.set_align('center')
    client_worksheet = workbook.add_worksheet('Clients')
    headers  = ["NGO Name",	"Client ID", "Status",	"Gender", "Date of Birth",	"Program Name", "Service Types",	"Accepted Date",	"Disabilities Yes/No",	"Current Province"]
    clients_data = []

    Organization.visible.oscar.pluck(:short_name, :full_name).each do |short_name, full_name|
      Apartment::Tenant.switch short_name

      quantitative_type_disability = QuantitativeType.pluck(:name).select{|custom_data| custom_data[/\/ History of disability and/i] }.first

      Client.active_status.joins(program_streams: :services).where(services: { name: ["Emergency foster care", "Long term foster care", "Kinship care"]}).each do |client|
        services = client.program_streams.map do |program_stream|
          "#{program_stream.name} => (#{program_stream.services.pluck(:name).uniq})"
        end.join(', ')

        qtypes = client.quantitative_cases.group_by(&:quantitative_type).map{|quantitative, quantitative_cases| [quantitative.name, quantitative_cases.map(&:value).join(', ')] }.to_h
        disability = qtypes[quantitative_type_disability] && qtypes[quantitative_type_disability][/child disabled/i].present? ? 'Yes' : 'No'
        clients_data << ["#{full_name}(#{short_name})", client.slug, client.status, client.gender.capitalize, format_date(client.date_of_birth), client.program_streams.pluck(:name).join(", "), services, format_date(client.accepted_date), disability, client.province.try(:name)]
      end
    end

    write_data_to_spreadsheet2(client_worksheet, headers, clients_data, format)
    workbook.close
  end

end