require "rails_helper"

RSpec.describe AbleScreeningMailer, type: :mailer do
  describe 'notify able screening' do
    let(:client) { create(:client, able_state: 'state') }
    let(:mail) { described_class.notify_able_manager(client).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Client Joint Able Program')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([ENV['ABLE_MANAGER_EMAIL']])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['info@cambodianfamilies.com'])
    end

    it 'assigns edit client url' do
      expect(mail.body.encoded).to match(edit_client_url(client, subdomain: Organization.current.short_name))
    end
  end
end
