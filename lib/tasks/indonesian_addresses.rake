namespace :indonesian_addresses do
  desc 'Import indonesian addresses'
  task :import, [:short_name] => :environment do |task, args|
    # url = 'https://alamat.thecloudalert.com/api/provinsi/get/'
    # response = service_request(url)
    short_name = args.short_name
    Apartment::Tenant.switch short_name
    import_province(short_name)
  end
end

def import_province(short_name)
  path = 'vendor/data/addressess/indonesia/provinces.xlsx'
  workbook = Roo::Excelx.new(path)
  data = (2..workbook.last_row).map do |row_index|
    id, name = workbook.row(row_index)
    "(#{id}, #{name}, #{id.to_s.rjust(2, '0')})"
  end.join(',')

  ActiveRecord::Base.connection.execute("INSERT INTO #{short_name}.provinces (id, name, code) VALUES #{values}")
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
