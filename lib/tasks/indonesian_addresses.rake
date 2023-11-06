namespace :indonesian_addresses do
  desc 'Import indonesian addresses'
  task :import, [:short_name] => :environment do |task, args|
    # url = 'https://alamat.thecloudalert.com/api/provinsi/get/'
    # response = service_request(url)
    short_name = args.short_name
    if short_name.present?
      Apartment::Tenant.switch short_name
      import_provinces(short_name)
      import_cities(short_name)
      import_districts(short_name)
      import_sub_districts(short_name)
    end
  end
end

def address_file_path(address_name)
  "vendor/data/addressess/indonesia/#{address_name}"
end

def import_provinces(short_name)
  path = address_file_path('provinces.xlsx')
  workbook = Roo::Excelx.new(path)
  return unless Province.count.zero?

  values = (2..workbook.last_row).map do |row_index|
    id, name = workbook.row(row_index)
    "(#{id}, '#{name}', #{id.to_s.rjust(2, '0')}, 'indonesia')"
  end.join(',')

  ActiveRecord::Base.connection.execute("INSERT INTO #{short_name}.provinces (id, name, code, country) VALUES #{values}")
end

def import_cities(short_name)
  path = address_file_path('cities.xlsx')
  workbook = Roo::Excelx.new(path)
  return unless City.count.zero?

  values = (2..workbook.last_row).map do |row_index|
    id, name, province_id = workbook.row(row_index)
    next if id == 'id'

    "(#{id}, '#{name}', #{province_id}, #{id})"
  end.compact.join(',')

  ActiveRecord::Base.connection.execute("INSERT INTO #{short_name}.cities (id, name, province_id, code) VALUES #{values}")
  puts '=======================Done import cities=================================='
end

def import_districts(short_name)
  path = address_file_path('districts.xlsx')
  workbook = Roo::Excelx.new(path)
  return unless District.count.zero?

  values = (2..workbook.last_row).map do |row_index|
    id, name, city_id = workbook.row(row_index)
    next if id == 'id'

    "(#{id}, '#{name}', #{city_id}, #{id})"
  end.compact.join(',')

  ActiveRecord::Base.connection.execute("INSERT INTO #{short_name}.districts (id, name, city_id, code) VALUES #{values}")
  puts '=======================Done import districts=================================='
end

def import_sub_districts(short_name)
  path = address_file_path('sub_districts.xlsx')
  workbook = Roo::Excelx.new(path)
  return unless Subdistrict.count.zero?

  values = (2..workbook.last_row).map do |row_index|
    id, name, district_id = workbook.row(row_index)
    next if id == 'id'

    "(#{id}, '#{name}', #{district_id}, '#{Date.today.to_s}', '#{Date.today.to_s}')"
  end.compact.join(',')

  ActiveRecord::Base.connection.execute("INSERT INTO #{short_name}.subdistricts (id, name, district_id, created_at, updated_at) VALUES #{values}")
  puts '=======================Done import subdistricts=================================='
end

def service_request(url)
  uri = URI.parse url
  res = JSON.parse Net::HTTP.get(uri)
  CSV.open(Rails.root.join('vendor/data/addressess/indonesia/provinces.csv'), 'w') do |csv|
    csv << ['id', 'Name']
    res['result'].each do |hash|
      collect_city(hash['id'])
      csv << hash.values
    end
  end
end

def collect_city(province_id)
  url = "https://alamat.thecloudalert.com/api/kabkota/get/?d_provinsi_id=#{province_id}"
  uri = URI.parse url
  res = JSON.parse Net::HTTP.get(uri)
  CSV.open(Rails.root.join('vendor/data/addressess/indonesia/cities.csv'), 'ab') do |csv|
    csv << ['id', 'Name', 'Province ID']
    res['result'].each do |hash|
      collect_district(hash['id'])
      csv << (hash.values << province_id)
    end
  end
end

def collect_district(city_id)
  url = "https://alamat.thecloudalert.com/api/kecamatan/get/?d_kabkota_id=#{city_id}"
  uri = URI.parse url
  res = JSON.parse Net::HTTP.get(uri)
  CSV.open(Rails.root.join('vendor/data/addressess/indonesia/districts.csv'), 'ab') do |csv|
    csv << ['id', 'Name', 'City ID']
    res['result'].each do |hash|
      collect_sub_district(hash['id'])
      csv << (hash.values << city_id)
    end
  end
end

def collect_sub_district(district_id)
  url = "https://alamat.thecloudalert.com/api/kelurahan/get/?d_kecamatan_id=#{district_id}"
  uri = URI.parse url
  res = JSON.parse Net::HTTP.get(uri)
  CSV.open(Rails.root.join('vendor/data/addressess/indonesia/sub_districts.csv'), 'ab') do |csv|
    csv << ['id', 'Name', 'District ID']
    res['result'].each do |hash|
      csv << (hash.values << district_id)
    end
  end
end
