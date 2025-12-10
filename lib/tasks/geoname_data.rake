namespace :geoname_data do
  desc 'Generate new address mapping from gazetteer data to geoname dataset structure'
  task mapping: :environment do
    if Rails.env.development?
      files = Dir.glob('vendor/data/addressess/xlsx/*.xlsx').reject { |filename| filename.include?('~') }
    else
      files = Dir.glob(Rails.root.join('../../shared/vendor/data/addressess/xlsx/*.xlsx')).reject { |filename| filename.include?('~') }
    end

    province_hash = { 'pursat' => 'Gazetteer_PUR', 'siemreap' => 'Gazetteer_SRP', 'oddar meanchey' => 'Gazetteer_OMC', 'pailin' => 'Gazetteer_PLN', 'preah vihear' => 'Gazetteer_PVR', 'stung treng' => 'Gazetteer_STG', 'kampong thom' => 'Gazetteer_KPT', 'tboung khmum' => 'Gazetteer_TKM', 'kep' => 'Gazetteer_KEP', 'preah sihanouk' => 'Gazetteer_SHV', 'ratanak kiri' => 'Gazetteer_RAT', 'kampong speu' => 'Gazetteer_KSP', 'kandal' => 'Gazetteer_KDL', 'prey veng' => 'Gazetteer_PVG', 'banteay meanchey' => 'Gazetteer_BMC', 'kampong cham' => 'Gazetteer_KPC', 'koh kong' => 'Gazetteer_KKG', 'svay rieng' => 'Gazetteer_SVR', 'battambang' => 'Gazetteer_BAT', 'kampot' => 'Gazetteer_KAM', 'takeo' => 'Gazetteer_TAK', 'phnom penh' => 'Gazetteer_PNP', 'kratie' => 'Gazetteer_KRT', 'kampong chhnang' => 'Gazetteer_KCH', 'mondul kiri' => 'Gazetteer_MKR' }
    province_code_hash = {
      'pursat' => '15',
      'siemreap' => '17',
      'oddar meanchey' => '22',
      'pailin' => '24',
      'preah vihear' => '13',
      'stung treng' => '19',
      'kampong thom' => '06',
      'tboung khmum' => '25',
      'kep' => '23',
      'preah sihanouk' => '18',
      'ratanak kiri' => '16',
      'kampong speu' => '05',
      'kandal' => '08',
      'prey veng' => '14',
      'banteay meanchey' => '01',
      'kampong cham' => '03',
      'koh kong' => '09',
      'svay rieng' => '20',
      'battambang' => '02',
      'kampot' => '07',
      'takeo' => '21',
      'phnom penh' => '12',
      'kratie' => '10',
      'kampong chhnang' => '04',
      'mondul kiri' => '11'
    }

    provinces = []
    Apartment::Tenant.switch('shared')

    provinces = Province.where(country: 'cambodia').or(Province.all).where.not(name: 'Kampong Cham/Prey Chhor/Communex')
    provinces_names = provinces.pluck(:code, :name)

    provinces_names.each do |pcode, pname|
      province_name_kh = pname.split('/').first.strip
      province_name_en = pname.split('/').last.strip.downcase

      gazetteer_short_name = province_hash[province_name_en]
      file_path = files.find { |filename| filename[/#{gazetteer_short_name}/] }
      GeonameData::Mapping.new(file_path, province_name_kh, province_name_en, pcode)
    end
  end
end
