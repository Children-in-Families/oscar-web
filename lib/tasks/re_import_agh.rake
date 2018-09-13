namespace :agh do
  desc 'Re-Import A Greater Hope data'
  task reimport: :environment do
    # org = Organization.create_and_build_tanent(short_name: 'agh', full_name: "A Greater Hope", logo: File.open(Rails.root.join('app/assets/images/agh.jpg')))
    # Organization.switch_to org.short_name
    Organization.switch_to 'agh'

    Client.all.each do |client|
      next unless client.kid_id.present?
      client.kid_id = client.kid_id.to_i.to_s
      client.save(validate: false)
    end

    import = AghReimporter::Import.new('Clients')
    import.clients
  end
end
