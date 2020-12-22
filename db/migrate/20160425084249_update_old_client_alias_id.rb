class UpdateOldClientAliasId < ActiveRecord::Migration[5.2]
  def change
    unprocessable_clients = []

    puts '========== Processing =========='

    Client.find_each do |client|
      slug = "#{ENV['ORGANISATION_ABBREVIATION']}-#{client.id}"
      begin
        client.update_attributes!(slug: slug)
      rescue
        unprocessable_clients << client.id
        puts "===== error client id #{client.id} ====="
      end
    end

    puts '==========Done=========='

    system "echo #{unprocessable_clients} >> error.txt" if unprocessable_clients.present?
  end
end
