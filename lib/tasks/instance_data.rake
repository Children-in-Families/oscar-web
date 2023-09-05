namespace :instance do
  desc 'Update count data to be used in MD'
  task update_count_data: :environment do
    Organization.without_shared.find_each do |org|
      Apartment::Tenant.switch(org.short_name) do
        org.update_columns(
          clients_count: Client.reportable.count,
          active_client: Client.reportable.active_status.count,
          accepted_client: Client.reportable.accepted.count,
          exited_client: Client.reportable.exited_ngo.count,
          users_count: User.non_devs.count,
          referred_count: Client.reportable.where(status: 'Referred').count,
        )
      end
    end
  end
end
