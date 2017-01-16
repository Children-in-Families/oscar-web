require 'rails_helper'

RSpec.describe Organization, type: :model do
  let!(:cif_org) { Organization.create_and_build_tanent(short_name: 'cif', full_name: 'Children in Family') }
  let!(:new_smile_org) { Organization.create_and_build_tanent(short_name: 'new-smile', full_name: 'New Smile') }

  describe 'Validation' do
    it { is_expected.to validate_presence_of(:short_name) }
    it { is_expected.to validate_presence_of(:full_name) }

    it { is_expected.to validate_uniqueness_of(:short_name).case_insensitive }
  end

  describe 'Association' do
    it { is_expected.to have_many(:employees) }
  end

  describe Organization, '.current' do
    it 'return cif org when current tenant is cif' do
      Apartment::Tenant.switch!('cif')
      expect(Organization.current).to eq(cif_org)
    end

    it 'does not return cif org when current tenant is on new-smile' do
      Apartment::Tenant.switch!('new-smile')
      expect(Organization.current).not_to eq(cif_org)
    end
  end

  describe Organization, '.create_and_build_tanent' do
    context 'Success' do
      it 'create organization record' do
        # binding.pry
        org = Organization.create_and_build_tanent(short_name: 'testing1', full_name: 'Testing')
        expect(org.persisted?).to be_truthy
      end

      it 'built a tanent' do
        org = Organization.create_and_build_tanent(short_name: 'testing2', full_name: 'Testing')
        tanent = Apartment::Tenant.switch!(org.short_name)
        expect(tanent).to include(org.short_name)
      end
    end
    context 'Fail' do
      it 'is unable to create organization record' do
        org = Organization.create_and_build_tanent(short_name: 'testing3')
        expect(org.persisted?).to be_falsey
      end
    end
  end
end
