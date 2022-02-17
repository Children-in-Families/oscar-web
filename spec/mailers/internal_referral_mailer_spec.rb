require "rails_helper"

RSpec.describe InternalReferralMailer, type: :mailer do
  describe "perform" do
    before {
      Apartment::Tenant.create('ratanak') rescue nil
      create(:organization, short_name: 'ratanak')
      Apartment::Tenant.switch 'ratanak'
    }
    let!(:user) { create(:user)}
    let!(:client) { create(:client) }
    let!(:program_stream) { create(:program_stream)}
    # Organization.switch_to Organization.current.short_name
    let(:mail) { InternalReferralMailer.send_to(user.id, user.first_name, user.email, client.id, program_stream.id ) }
    it "renders the headers" do
      expect(mail.subject).to eq("New internal referral")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV['SENDER_EMAIL']])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(user.first_name)
    end
  end

end
