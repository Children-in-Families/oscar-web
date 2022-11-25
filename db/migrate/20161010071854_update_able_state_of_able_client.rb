class UpdateAbleStateOfAbleClient < ActiveRecord::Migration[5.2]
  def change
    unprocessable_clients = []

    puts '==========Processing=========='

    Client.find_each do |client|
      begin
        client.update_attributes!(able_state: 'Accepted') if client.able
      rescue
        unprocessable_clients << client.id
      end
    end

    puts '==========Done=========='

    system "echo #{unprocessable_clients} >> error.txt" if unprocessable_clients.present?
  end
end
