namespace :communes_and_villages do
  desc 'Import all communes and villages provided by NCDD'
  task :import, [:tenant] => [:environment] do |task, args|
    if Rails.env.development?
      files = Dir.glob("vendor/data/villages/xlsx/*.xlsx").reject{|filename| filename.include?('~') }
    else
      files = Dir.glob(Rails.root.join('../../shared/vendor/data/villages/xlsx/*.xlsx')).reject{|filename| filename.include?('~') }
    end

    Organization.switch_to args[:tenant] if args[:tenant]
    puts "START | #{Organization.current.short_name} | at #{Time.now.to_s}"

    # files.each do |file_name|
    #   puts "Importing: #{file_name}"
    #   import = VillageImporter::Import.new(file_name)
    #   import.communes_and_villages
    # end
    province_hash = { "pursat" => "Gazetteer_PUR", "siemreap" => "Gazetteer_SRP", "oddar meanchey" => "Gazetteer_OMC", "pailin" => "Gazetteer_PLN", "preah vihear" => "Gazetteer_PVR", "stung treng" => "Gazetteer_STG", "kampong thom" => "Gazetteer_KPT", "tboung khmum" => "Gazetteer_TKM", "kep" => "Gazetteer_KEP", "preah sihanouk" => "Gazetteer_SHV", "ratanak kiri" => "Gazetteer_RAT", "kampong speu" => "Gazetteer_KSP", "kandal" => "Gazetteer_KDL", "prey veng" => "Gazetteer_PVG", "banteay meanchey" => "Gazetteer_BMC", "kampong cham" => "Gazetteer_KPC", "koh kong" => "Gazetteer_KKG", "svay rieng" => "Gazetteer_SVR", "battambang" => "Gazetteer_BAT", "kampot" => "Gazetteer_KAM", "takeo" => "Gazetteer_TAK", "phnom penh" => "Gazetteer_PNP", "kratie" => "Gazetteer_KRT", "kampong chhnang" => "Gazetteer_KCH", "mondul kiri" => "Gazetteer_MKR" }

    Province.where(country: 'cambodia').where.not(name: "Kampong Cham/Prey Chhor/Communex").pluck(:id, :name).each do |id, province_name|
      pname = province_name.split('/').last.squish.downcase
      gazetteer_short_name = province_hash[pname]
      path  = files.find{|filename| filename[/#{gazetteer_short_name}/] }

      next if path.blank?

      data = Importer::Data.new(id, path)
      data.import
    end

    puts "FINISH | #{Organization.current.short_name} | at #{Time.now.to_s}"
  end
end
