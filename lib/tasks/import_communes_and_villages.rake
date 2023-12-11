namespace :communes_and_villages do
  desc 'Import all communes and villages provided by NCDD'
  task :import, [:tenant] => [:environment] do |task, args|
    if Rails.env.development?
      files = Dir.glob("vendor/data/addressess/xlsx/*.xlsx").reject{|filename| filename.include?('~') }
    else
      files = Dir.glob(Rails.root.join('../../shared/vendor/data/addressess/xlsx/*.xlsx')).reject{|filename| filename.include?('~') }
    end

    province_hash = { "pursat" => "Gazetteer_PUR", "siemreap" => "Gazetteer_SRP", "oddar meanchey" => "Gazetteer_OMC", "pailin" => "Gazetteer_PLN", "preah vihear" => "Gazetteer_PVR", "stung treng" => "Gazetteer_STG", "kampong thom" => "Gazetteer_KPT", "tboung khmum" => "Gazetteer_TKM", "kep" => "Gazetteer_KEP", "preah sihanouk" => "Gazetteer_SHV", "ratanak kiri" => "Gazetteer_RAT", "kampong speu" => "Gazetteer_KSP", "kandal" => "Gazetteer_KDL", "prey veng" => "Gazetteer_PVG", "banteay meanchey" => "Gazetteer_BMC", "kampong cham" => "Gazetteer_KPC", "koh kong" => "Gazetteer_KKG", "svay rieng" => "Gazetteer_SVR", "battambang" => "Gazetteer_BAT", "kampot" => "Gazetteer_KAM", "takeo" => "Gazetteer_TAK", "phnom penh" => "Gazetteer_PNP", "kratie" => "Gazetteer_KRT", "kampong chhnang" => "Gazetteer_KCH", "mondul kiri" => "Gazetteer_MKR" }
    province_code_hash = {
      "pursat" => "15",
      "siemreap" => "17",
      "oddar meanchey" => "22",
      "pailin" => "24",
      "preah vihear" => "13",
      "stung treng" => "19",
      "kampong thom" => "06",
      "tboung khmum" => "25",
      "kep" => "23",
      "preah sihanouk" => "18",
      "ratanak kiri" => "16",
      "kampong speu" => "05",
      "kandal" => "08",
      "prey veng" => "14",
      "banteay meanchey" => "01",
      "kampong cham" => "03",
      "koh kong" => "09",
      "svay rieng" => "20",
      "battambang" => "02",
      "kampot" => "07",
      "takeo" => "21",
      "phnom penh" => "12",
      "kratie" => "10",
      "kampong chhnang" => "04",
      "mondul kiri" => "11"
    }

    if args[:tenant]
      pp "START | #{args[:tenant]} | at #{Time.now.to_s}"

      import_addresses(args[:tenant], files, province_hash, province_code_hash)

      pp "FINISH | #{args[:tenant]} | at #{Time.now.to_s}"
    else
      organization_ids = Organization
                            .where(country: 'cambodia')
                            .pluck(:id, :short_name)

      organization_ids.each do |id, tenant_name|
        pp "START | #{tenant_name} | at #{Time.now.to_s}"

        import_addresses(tenant_name, files, province_hash, province_code_hash)

        pp "FINISH | #{tenant_name} | at #{Time.now.to_s}"
      end
    end

  end
end

def import_addresses(tenant_name, files, province_hash, province_code_hash)
  return if tenant_name.nil?

  Organization.switch_to(tenant_name)

  provinces = Province.where(country: 'cambodia').or(Province.all)
                      .where.not(name: "Kampong Cham/Prey Chhor/Communex")
                      .to_a

  provinces.each do |province|
    pname = province.name.split('/').last.squish.downcase
    gazetteer_short_name = province_hash[pname]
    path = files.find { |filename| filename[/#{gazetteer_short_name}/] }

    if province.code.blank?
      province.code = province_code_hash[pname]
      province.save
    end

    next if path.blank?

    data = Importer::Data.new(province.id, path)
    data.import
  end
end
