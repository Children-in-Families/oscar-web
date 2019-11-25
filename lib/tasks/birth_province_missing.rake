namespace :birth_province_missing do
  desc "TODO"
  task restore: :environment do
    Organization.all.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name
      provinces_hash = {2=>[246, "សៀមរាប / Siemreap"], 8=>[243, "ព្រះសីហនុ / Preah Sihanouk"], 13=>[245, "មណ្ឌលគិរី / Mondul Kiri"], 17=>[247, "បន្ទាយមានជ័យ / Banteay Meanchey"], 18=>[244, "រតនគិរី / Ratanak Kiri"], 21=>[45, "ត្បូងឃ្មុំ / Tboung Khmum"], 27=>[6, "ស្ទឹងត្រែង / Stung Treng"], 28=>[11, "ស្វាយរៀង / Svay Rieng"], 29=>[20, "កំពង់ឆ្នាំង / Kampong Chhnang"], 30=>[9, "កំពង់ស្ពឺ / Kampong Speu"], 33=>[22, "បាត់ដំបង / Battambang"], 34=>[23, "កំពង់ធំ / Kampong Thom"], 36=>[25, "តាកែវ / Takeo"], 38=>[243, "ព្រះសីហនុ / Preah Sihanouk"], 40=>[247, "បន្ទាយមានជ័យ / Banteay Meanchey"]}
      Client.where(birth_province_id: [2, 8, 13, 17, 18, 21, 27, 28, 29, 30, 33, 34, 36, 38, 40]).order(:birth_province_id).each do |client|
        updated_province = provinces_hash[client.birth_province_id]
        client.update_column(:birth_province_id, updated_province.first)
      end
      puts "#{short_name} done!!!"
    end

  end

end
