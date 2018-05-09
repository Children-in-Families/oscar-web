class SharedClientMailer < ApplicationMailer
  def notify_of_shared_client(shared_client_id, origin_ngo)
    Organization.switch_to origin_ngo
    shared_client = SharedClient.find_by(id: shared_client_id)
    @origin_organization = Organization.current

    # @origin_ngo = shared_client.origin_ngo

    # client = Client.find_by(id: shared_client.client_id)
    fields = shared_client.fields
    @fields = Hash[fields.collect { |item| [item.titleize, shared_client.client.send(item)] } ]
    # @fields = {'Gender' => 'Male', 'Name' => 'Pirun'}
    # @client_id = shared_client.client.slug
    @client_id = shared_client.client.origin_id || shared_client.client.slug
    Organization.switch_to shared_client.destination_ngo
    @destination_ngo = shared_client.destination_ngo
    admin_emails = User.admins.pluck(:email)

    mail(to: admin_emails, subject: 'New Referral Client')
  end
end
