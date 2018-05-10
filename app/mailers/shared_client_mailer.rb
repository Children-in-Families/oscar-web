class SharedClientMailer < ApplicationMailer
  def notify_of_shared_client(shared_client_id, referred_from)
    Organization.switch_to referred_from
    @shared_client = SharedClient.find_by(id: shared_client_id)
    @origin_organization = Organization.current

    fields = @shared_client.fields
    @fields = Hash[fields.collect { |item| [item.titleize, @shared_client.client.send(item)] } ]

    @client_id = @shared_client.client.origin_id.present? ? @shared_client.client.origin_id : @shared_client.client.slug
    Organization.switch_to @shared_client.referred_to

    admin_emails = User.admins.pluck(:email)

    mail(to: admin_emails, subject: 'New Referral Client')
  end
end
