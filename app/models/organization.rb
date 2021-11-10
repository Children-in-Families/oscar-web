require 'rake'
class Organization < ActiveRecord::Base
  SUPPORTED_LANGUAGES = %w(en km my).freeze

  has_paper_trail on: :update, only: :integrated
  mount_uploader :logo, ImageUploader

  has_many :employees, class_name: 'User'

  has_many :donor_organizations, dependent: :destroy
  has_many :donors, through: :donor_organizations
  has_many :global_identity_organizations, dependent: :destroy

  scope :without_demo, -> { where.not(full_name: 'Demo') }
  scope :without_cwd, -> { where.not(short_name: 'cwd') }
  scope :without_shared, -> { where.not(short_name: 'shared') }
  scope :exclude_current, -> { where.not(short_name: Organization.current.short_name) }
  scope :oscar, -> { visible.where(demo: false) }
  scope :visible, -> { where.not(short_name: ['cwd', 'myan', 'rok', 'shared', 'my', 'tutorials']) }
  scope :test_ngos, -> { where(short_name: ['demo', 'tutorials']) }
  scope :cambodian, -> { where(country: 'cambodia') }
  scope :skip_dup_checking_orgs, -> { where(short_name: ['demo', 'cwd', 'myan', 'rok', 'my']) }
  scope :only_integrated, -> { where(integrated: true) }

  before_save :clean_supported_languages

  validates :full_name, :short_name, presence: true
  validates :short_name, uniqueness: { case_sensitive: false }

  before_save :clean_short_name, on: :create
  before_save :clean_supported_languages, if: :supported_languages?
  after_commit :upsert_referral_source_category, on: [:create, :update]
  after_commit :delete_referral_source_category, on: :destroy

  class << self
    def current
      find_by(short_name: Apartment::Tenant.current)
    end

    def switch_to(tenant_name)
      Apartment::Tenant.switch!(tenant_name)
    end

    def create_and_build_tenant(fields = {})
      transaction do
        org = new(fields)
        if org.save
          Apartment::Tenant.create(org.short_name)
          org
        else
          false
        end
      end
    end

    def seed_generic_data(org_id, referral_source_category_name=nil)
      org = find_by(id: org_id)
      if org
        CifWeb::Application.load_tasks
        service_data_file = Rails.root.join('lib/devdata/services/service.xlsx')
        Apartment::Tenant.switch(org.short_name) do
          country = org.try(:country)
          if country == 'nepal'
            general_data_file = Rails.root.join('lib/devdata/general_en.xlsx')
          else
            general_data_file = Rails.root.join('lib/devdata/general.xlsx')
          end
          Rake::Task['db:seed'].invoke
          Rake::Task['db:seed'].reenable
          ImportStaticService::DateService.new('Services', org.short_name, service_data_file).import
          Importer::Import.new('Agency', general_data_file).agencies
          Importer::Import.new('Department', general_data_file).departments
          if country == 'nepal'
            Rake::Task['nepali_provinces:import'].invoke(org.short_name)
          elsif country == 'haiti'
            Rake::Task['haiti_addresses:import'].invoke(org.short_name)
            Rake::Task['haiti_addresses:import'].reenable
          else
            Importer::Import.new('Province', general_data_file).provinces
            Rake::Task['communes_and_villages:import'].invoke(org.short_name)
            Rake::Task['communes_and_villages:import'].reenable
          end
          Importer::Import.new('Quantitative Type', general_data_file).quantitative_types
          Importer::Import.new('Quantitative Case', general_data_file).quantitative_cases
          Rake::Task["field_settings:import"].invoke(org.short_name)
          Rake::Task["field_settings:import"].reenable
          referral_source_category = ReferralSource.find_by(name_en: referral_source_category_name)
          if referral_source_category
            referral_source = ReferralSource.find_or_create_by(name: "#{org.full_name} - OSCaR Referral")
            referral_source.update_attributes(ancestry: "#{referral_source_category.id}")
          else
            ReferralSource.find_or_create_by(name: "#{org.full_name} - OSCaR Referral")
          end
        end
        Rake::Task['haiti_addresses:import'].invoke('shared')
        Rake::Task['haiti_addresses:import'].reenable
        Apartment::Tenant.switch(org.short_name)
      end
    end

    def brc?
      current&.short_name == 'brc'
    end

    def shared?
      current&.short_name == 'shared'
    end

    def ratanak?
      current&.short_name == 'ratanak'
    end
  end

  def demo?
    short_name == 'demo'
  end

  def mho?
    short_name == 'mho'
  end

  def cif?
    short_name == 'cif'
  end

  def cwd?
    short_name == 'cwd'
  end

  def cccu?
    short_name == 'cccu'
  end

  def clean_short_name
    self.short_name = short_name.parameterize
  end

  def clean_supported_languages
    self.supported_languages = supported_languages.select(&:present?)
  end

  def available_for_referral?
    if Rails.env.production?
      Organization.test_ngos.pluck(:short_name).include?(self.short_name) || Organization.oscar.pluck(:short_name).include?(self.short_name)
    else
      Organization.test_ngos.pluck(:short_name).include?(self.short_name) || Organization.visible.pluck(:short_name).include?(self.short_name)
    end
  end

  private

  def upsert_referral_source_category
    current_org = Apartment::Tenant.current
    org_full_name = self.full_name
    rs_category_name = self.referral_source_category_name

    Organization.all.pluck(:short_name).each do |org_short_name|
      Apartment::Tenant.switch! org_short_name
      referral_source = ReferralSource.find_or_create_by(name: "#{org_full_name} - OSCaR Referral")
      rs_category = ReferralSource.find_by(name_en: rs_category_name)
      referral_source.update_attributes(ancestry: "#{rs_category.id}") if rs_category
    end
    Apartment::Tenant.switch! current_org
  end

  def delete_referral_source_category
    org_full_name = self.full_name
    Organization.all.pluck(:short_name).each do |org_short_name|
      Apartment::Tenant.switch! org_short_name
      referral_source = ReferralSource.find_by(name: "#{org_full_name} - OSCaR Referral")
      referral_source.destroy if referral_source
    end
  end
end
