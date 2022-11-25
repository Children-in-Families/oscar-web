class SplitClientNameToFirstNameAndLastName < ActiveRecord::Migration[5.2]
  def change
    unprocessable_clients = []

    puts '==========Processing=========='

    Client.find_each do |client|
      if client.last_name.blank?
        begin
          name = client.first_name.split(' ')
          client_first_name = name[0].present? ? name[0] : ''
          client_last_name = ''
          name.drop(1).each do |last_name|
            client_last_name += last_name.present? ? last_name : ''
          end
          client.update_attributes!(first_name: client_first_name)
          client.update_attributes!(last_name: client_last_name)
        rescue
          unprocessable_clients << client.id
        end
      end
    end
    puts '==========Done=========='

    system "echo #{unprocessable_clients} >> error.txt" if unprocessable_clients.present?
  end
end
