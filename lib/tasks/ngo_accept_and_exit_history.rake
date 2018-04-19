namespace :ngo_accept_and_exit_history do
  desc 'Migrate client history data of accepting and exiting NGO'
  task migrate: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      Client.where(state: 'accepted', accepted_date: nil).each do |client|
        client.update_columns(accepted_date: client.created_at.to_date)
      end

      entered_ngo_clients = Client.where.not(accepted_date: nil)

      entered_ngo_clients.each do |client|
        enter_ngo = client.enter_ngos.new(accepted_date: client.accepted_date)
        enter_ngo.save(validate: false)
      end

      exited_ngo_clients = Client.where.not(exit_date: nil)

      exited_ngo_clients.each do |client|
        exit_ngo = client.exit_ngos.new(
                                    exit_date: client.exit_date,
                                    exit_note: client.exit_note,
                                    exit_circumstance: client.exit_circumstance,
                                    exit_reasons: client.exit_reasons)
        exit_ngo.save(validate: false)
      end
    end
  end
end
