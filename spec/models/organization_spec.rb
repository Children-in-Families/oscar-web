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

  describe Organization, '#raise_error_non_public_tenant' do
    it 'raises error when create non public tenant' do
      Apartment::Tenant.switch!('cif')
      org = Organization.create(short_name: 'test', full_name: 'New Test')
      expect(org.errors).to include(:non_public_tenant)
    end

    it 'does not railse error when create on public tenant' do
      Apartment::Tenant.switch!('public')
      org = Organization.create(short_name: 'test', full_name: 'New Test')
      expect(org.errors).not_to include(:non_public_tenant)
    end
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
        org = Organization.create_and_build_tanent(short_name: 'testing', full_name: 'Testing')
        expect(org.persisted?).to be_truthy
      end

      it 'built a tanent' do
        org = Organization.create_and_build_tanent(short_name: 'testing', full_name: 'Testing')
        tanent = Apartment::Tenant.switch!(org.short_name)
        expect(tanent).to include(org.short_name)
      end
    end
    context 'Fail' do
      it 'is unable to create organization record' do
        org = Organization.create_and_build_tanent(short_name: 'testing')
        expect(org.persisted?).to be_falsey
      end
    end
  end
end
