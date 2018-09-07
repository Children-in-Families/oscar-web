namespace :cambodia_geography_correction do
  desc 'Update geography to match with data provided by NCDD'
  task start: :environment do

    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      correct_provinces
      correct_districts
    end
  end
end

private

def correct_provinces
  bmc_pro = Province.find_by(name: 'បន្ទាយមានជ័យ / Banteay Meanchay')
  bmc_pro.update(name: 'បន្ទាយមានជ័យ / Banteay Meanchey') if bmc_pro.present?

  mdk_pro = Province.find_by(name: 'មណ្ឌលគីរី / Mondulkiri')
  mdk_pro.update(name: 'មណ្ឌលគិរី / Mondul Kiri') if mdk_pro.present?

  rtk_pro = Province.find_by(name: 'រតនគីរី / Ratanakiri')
  rtk_pro.update(name: 'រតនគិរី / Ratanak Kiri') if rtk_pro.present?

  sr_pro = Province.find_by(name: 'សៀមរាប / Siem Reap')
  sr_pro.update(name: 'សៀមរាប / Siemreap') if sr_pro.present?

  omc_pro = Province.find_by(name: 'ឧត្តរមានជ័យ / Oddar Meanchay')
  omc_pro.update(name: 'ឧត្ដរមានជ័យ / Oddar Meanchey') if omc_pro.present?

  shv_pro = Province.find_by(name: 'ព្រះសីហនុ / Preah Sihannouk')
  shv_pro.update(name: 'ព្រះសីហនុ / Preah Sihanouk') if shv_pro.present?
end

def correct_districts
  District.where('name ilike ?', '% / Krong %').each do |district|
    name = district.name.gsub('Krong ', '')
    district.update(name: name)
  end

  kpl = District.find_by(name: 'ពោធិ៍រៀង / Kampong Leav')
  kpl.update(name: 'ពោធិ៍រៀង / Pur Rieng') if kpl.present?

  punhea_leu = District.find_by(name: 'ពញាឮ / Popnhea Lueu')
  punhea_leu.update(name: 'ពញាឮ / Ponhea Lueu') if punhea_leu.present?

  koh_kong_1 = District.find_by(name: 'កោះកុង / Koh Kong')
  koh_kong_1.update(name: 'កោះកុង / Kaoh Kong') if koh_kong_1.present?

  koh_kong_2 = District.find_by(name: "ខេមរភូមិន្ទ / Khemarak Phoumin")
  koh_kong_2.update(name: "ខេមរភូមិន្ទ / Khemara Phoumin") if koh_kong_2.present?

  krt_1 = District.find_by(name: "ក្រចេះ / Chetr Borei")
  krt_1.update(name: 'ចិត្របុរី / Chetr Borei') if krt_1.present?
  krt_3 = District.find_by(name: "ចិត្របុរី / Chitr Borie")
  krt_3.update(name: 'ចិត្របុរី / Chetr Borei') if krt_3.present?

  krt_2 = District.find_by(name: "ព្រែកប្រសព្វ / Preaek Prasab")
  krt_2.update(name: "ព្រែកប្រសព្វ / Prek Prasab") if krt_2.present?

  btb_1 = District.find_by(name: "ភ្នំព្រឹក / Phnom Proek")
  btb_1.update(name: "ភ្នំព្រឹក / Phnum Proek") if btb_1.present?
  btb_2 = District.find_by(name: "រុក្ខគិរី / Rukhak Kiri")
  btb_2.update(name: "រុក្ខគិរី / Rukh Kiri") if btb_2.present?

  pvh_1 = District.find_by(name: "ជាំក្សាន្ដ / Choam Khsant")
  pvh_1.update(name: "ជាំក្សាន្ដ / Choam Ksant") if pvh_1.present?

  pp_1 = District.find_by(name: "ពោធិសែនជ័យ / Por Senchey")
  pp_1.update(name: "ពោធិសែនជ័យ / Pur SenChey") if pp_1.present?
  pp_2 = District.find_by(name: "ព្រែកព្នៅ / Preaek Pnov")
  pp_2.update(name: "ព្រែកព្នៅ / Praek Pnov") if pp_2.present?
  pp_3 = District.find_by(name: "ឫស្សីកែវ / Ruessei Kaev")
  pp_3.update(name: "ឫស្សីកែវ / Russey Keo") if pp_3.present?
  pp_4 = District.find_by(name: "ជ្រោយចង្វារ / Chrouy Changva")
  pp_4.update(name: "ជ្រោយចង្វារ / Chraoy Chongvar") if pp_4.present?

  sr_1 = District.find_by(name: "សៀមរាប / Siem Reab")
  sr_1.update(name: "សៀមរាប / Siem Reap") if sr_1.present?
end
