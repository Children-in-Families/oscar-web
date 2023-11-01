require 'uri'
require 'net/http'
require 'net/https'

namespace :indonesian_addresses do
  desc 'Import indonesian addresses'
  task :import, [:short_name] => :environment do |task, args|
    url = 'https://alamat.thecloudalert.com/api/provinsi/get/'
    response = service_request(url)
  end
end

def service_request(url)
  uri = URI.parse url
  http = Net::HTTP.new(uri.host, 443)
  req = Net::HTTP::Get.new uri.path
  # http.use_ssl = true
  # http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  # http.cert_store = OpenSSL::X509::Store.new
  # http.cert_store.set_default_paths

  # http.cert_store.add_file(Rails.root.join('vendor/data/cacert.pem').to_s)
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  res = http.request req, ''
end
