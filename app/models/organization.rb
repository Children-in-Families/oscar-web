class Organization < ActiveRecord::Base
  SUPPORTED_LANGUAGES = %w(en km my).freeze

  mount_uploader :logo, ImageUploader

  has_many :employees, class_name: 'User'

  has_many :donor_organizations, dependent: :destroy
  has_many :donors, through: :donor_organizations

  scope :without_demo, -> { where.not(full_name: 'Demo') }
  scope :without_cwd, -> { where.not(short_name: 'cwd') }
  scope :without_shared, -> { where.not(short_name: 'shared') }
  scope :exclude_current, -> { where.not(short_name: Organization.current.short_name) }
  scope :oscar, -> { visible.where.not(short_name: 'demo') }
  scope :visible, -> { where.not(short_name: ['cwd', 'myan', 'rok', 'shared', 'my', 'tutorials']) }
  scope :test_ngos, -> { where(short_name: ['demo', 'tutorials']) }
  scope :cambodian, -> { where(country: 'cambodia') }
  scope :skip_dup_checking_orgs, -> { where(short_name: ['demo', 'cwd', 'myan', 'rok', 'my']) }
  scope :only_integrated, -> { where(integrated: true) }

  validates :full_name, :short_name, presence: true
  validates :short_name, uniqueness: { case_sensitive: false }

  before_save :clean_short_name, on: :create

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

    def create_and_seed_generic_data(fields = {})
      org = new(fields)

      if org.save
        Apartment::Tenant.create(org.short_name)

        general_data_file = 'lib/devdata/general.xlsx'
        service_data_file = 'lib/devdata/services/service.xlsx'

        CifWeb::Application.load_tasks

        Apartment::Tenant.switch(org.short_name) do
          Rake::Task['db:seed'].invoke
          ImportStaticService::DateService.new('Services', org.short_name, service_data_file).import
          Importer::Import.new('Agency', general_data_file).agencies
          Importer::Import.new('Department', general_data_file).departments
          Importer::Import.new('Province', general_data_file).provinces

          Rake::Task['communes_and_villages:import'].invoke
          Rake::Task['communes_and_villages:import'].reenable
          Importer::Import.new('Quantitative Type', general_data_file).quantitative_types
          Importer::Import.new('Quantitative Case', general_data_file).quantitative_cases
          Rake::Task["field_settings:import"].invoke(org.short_name)
        end

        org
      else
        false
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

  def available_for_referral?
    if Rails.env.production?
      Organization.test_ngos.pluck(:short_name).include?(self.short_name) || Organization.oscar.pluck(:short_name).include?(self.short_name)
    else
      Organization.test_ngos.pluck(:short_name).include?(self.short_name) || Organization.visible.pluck(:short_name).include?(self.short_name)
    end
  end
end
