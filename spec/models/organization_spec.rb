require 'rails_helper'

RSpec.describe Organization, type: :model do
  let!(:cif_org) { Organization.create_and_build_tanent(short_name: 'cif', full_name: 'Children in Family') }
  let!(:new_smile_org) { Organization.create_and_build_tanent(short_name: 'new-smile', full_name: 'New Smile') }
  let!(:cwd_org) { Organization.create_and_build_tanent(short_name: 'cwd', full_name: 'cwd') }

  describe Organization, 'Scopes' do
    it 'without demo' do
      orgs = Organization.without_demo
      expect(orgs).to include(cif_org, new_smile_org, cwd_org)
    end

    it 'without cwd' do
      orgs = Organization.without_cwd
      expect(orgs).to include(cif_org, new_smile_org)
      expect(orgs).not_to include(cwd_org)
    end

    it 'without demo and cwd' do
      orgs = Organization.without_demo_and_cwd
      expect(orgs).to include(cif_org, new_smile_org)
      expect(orgs).not_to include(cwd_org)
    end
  end

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

  describe Organization, 'instance methods' do
    context 'demo?' do
      demo_instance = Organization.find_by(short_name: 'demo')
      demo_instance = demo_instance.present? ? demo_instance : Organization.create_and_build_tanent(short_name: 'demo', full_name: 'Demo')
      app_instance  = Organization.find_by(short_name: 'app')
      app_instance = app_instance.present? ? app_instance : Organization.create_and_build_tanent(short_name: 'app', full_name: 'App')
      it { expect(demo_instance.demo?).to be_truthy }
      it { expect(app_instance.demo?).to be_falsey }
    end

    context 'mho?' do
      mho_instance = Organization.find_by(short_name: 'mho')
      mho_instance = mho_instance.present? ? mho_instance : Organization.create_and_build_tanent(short_name: 'mho', full_name: 'mho')
      app_instance  = Organization.find_by(short_name: 'app')
      app_instance = app_instance.present? ? app_instance : Organization.create_and_build_tanent(short_name: 'app', full_name: 'App')
      it { expect(mho_instance.mho?).to be_truthy }
      it { expect(app_instance.mho?).to be_falsey }
    end
  end
end
