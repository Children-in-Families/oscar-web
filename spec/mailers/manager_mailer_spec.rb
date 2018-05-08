require "rails_helper"

RSpec.describe ManagerMailer, type: :mailer do
  xdescribe 'remind_of_client', skip: '====== Will be reimplemented with EC CPS ======' do
    let!(:admin) { create(:user, :admin)}
    let!(:client) { create(:client, status: 'Active') }
    let!(:case){ create(:case, :emergency, client: client) }
    let(:mail) { AdminMailer.remind_of_client([client], day: '90', admin: admin).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Reminder [Clients Are About To Exit Emergency Care Program]')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(admin.to_s)
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([ENV['SENDER_EMAIL']])
    end

    it 'assigns edit client url' do
      expect(mail.body.encoded).to include(client_url(client, subdomain: Organization.current.short_name))
    end
  end
end
