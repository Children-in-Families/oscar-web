require 'rake'

class Organization < ActiveRecord::Base
  SUPPORTED_LANGUAGES = %w(en km my).freeze
  TYPES = ['Faith Based Organization', 'Government Organization', "Disabled People's Organization", 'Non Government Organization', 'Community Based Organization', 'Other Organization'].freeze

  acts_as_paranoid
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
  scope :visible, -> { where.not(short_name: ['cwd', 'myan', 'rok', 'shared', 'my', 'tutorials', 'cifcp']) }
  scope :visible_only_cif, -> { where.not(short_name: ['cwd', 'myan', 'rok', 'shared', 'my', 'tutorials']) }
  scope :test_ngos, -> { where(short_name: ['demo', 'tutorials']) }
  scope :cambodian, -> { where(country: 'cambodia') }
  scope :skip_dup_checking_orgs, -> { where(short_name: ['demo', 'cwd', 'myan', 'rok', 'my']) }
  scope :only_integrated, -> { where(integrated: true) }
  scope :completed, -> { where(onboarding_status: 'completed') }

  before_save :clean_supported_languages

  validates :full_name, :short_name, presence: true
  validates :short_name, uniqueness: { case_sensitive: false }
  validates :last_integrated_date, presence: true, if: :integrated?

  before_save :clean_short_name, on: :create
  before_save :clean_supported_languages, if: :supported_languages?
  after_commit :upsert_referral_source_category, on: [:update]
  after_commit :delete_referral_source_category, on: :destroy
  after_commit :flush_cache

  class << self
    def current
      Rails.cache.fetch(['current_organization', Apartment::Tenant.current, Organization.only_deleted.count]) do
        find_by(short_name: Apartment::Tenant.current)
      end
    end

    def switch_to(tenant_name)
      Apartment::Tenant.switch!(tenant_name)
      puts "====================== Switching to #{tenant_name} ======================"
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

    def seed_generic_data(org_id, referral_source_category_name = nil)
      org = find_by(id: org_id)
      db_value = ENV['DB']

      if org
        Rake::Task.clear
        CifWeb::Application.load_tasks
        service_data_file = Rails.root.join('lib/devdata/services/service.xlsx')
        Apartment::Tenant.switch(org.short_name) do
          country = org.try(:country)
          if country == 'nepal'
            general_data_file = Rails.root.join('lib/devdata/general_en.xlsx')
          else
            general_data_file = Rails.root.join('lib/devdata/general.xlsx')
          end

          if country == 'ratanak'
            setting = Setting.first_or_create(default_assessment: 'Results Framework Assessment', country_name: country, enable_hotline: true, min_assessment: 3, case_note_frequency: 'day', max_case_note: 30, age: 100)
          else
            setting = Setting.first_or_create(country_name: country, min_assessment: 3, case_note_frequency: 'day', max_case_note: 30)
          end

          setting.update(org_name: org.full_name) if setting.org_name.blank? && org.present?

          Rake::Task['global_service:drop_constrain'].invoke(org.short_name)
          Rake::Task['global_service:drop_constrain'].reenable

          ENV['DB'] = org.short_name # This will seed data only for the current tenant
          Rake::Task['db:seed'].invoke
          Rake::Task['db:seed'].reenable

          Importer::Import.new('Agency', general_data_file).agencies
          Importer::Import.new('Department', general_data_file).departments
          case country
          when 'nepal'
            Rake::Task['nepali_provinces:import'].invoke(org.short_name)
            Rake::Task['nepali_provinces:import'].reenable
          when 'haiti'
            Rake::Task['haiti_addresses:import'].invoke(org.short_name)
            Rake::Task['haiti_addresses:import'].reenable
          when 'thailand'
            Rake::Task['thailand_addresses:import'].invoke(org.short_name)
            Rake::Task['thailand_addresses:import'].reenable
          else
            Importer::Import.new('Province', general_data_file).provinces
            Rake::Task['communes_and_villages:import'].invoke(org.short_name)
            Rake::Task['communes_and_villages:import'].reenable
          end
          Importer::Import.new('Quantitative Type', general_data_file).quantitative_types
          Importer::Import.new('Quantitative Case', general_data_file).quantitative_cases
          Rake::Task['field_settings:import'].invoke(org.short_name)
          Rake::Task['field_settings:import'].reenable

          Thredded::MessageboardGroup.find_or_create_by(name: 'Archived', position: 0)

          referral_source_category = ReferralSource.find_by(name_en: referral_source_category_name)
          if referral_source_category
            referral_source = ReferralSource.find_or_create_by(name: "#{org.full_name} - OSCaR Referral")
            referral_source.update_attributes(ancestry: "#{referral_source_category.id}")
          else
            ReferralSource.find_or_create_by(name: "#{org.full_name} - OSCaR Referral")
          end
        end

        ENV['DB'] = db_value
      end
    end

    def brc?
      Apartment::Tenant.current == 'brc'
    end

    def shared?
      Apartment::Tenant.current == 'shared'
    end

    def ratanak?
      Apartment::Tenant.current == 'ratanak'
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

  # To Do: Maybe allow user to select which language they want to use
  def local_language
    other_languages = (supported_languages - ['en'])

    return 'km' if cambodian? && other_languages.include?('km')
    return 'my' if myanmar? && other_languages.include?('my')

    other_languages.first
  end

  def cambodian?
    country == 'cambodia'
  end

  def myanmar?
    country == 'myanmar'
  end

  def available_for_referral?
    if Rails.env.production?
      Organization.test_ngos.pluck(:short_name).include?(self.short_name) || Organization.oscar.pluck(:short_name).include?(self.short_name)
    else
      Organization.test_ngos.pluck(:short_name).include?(self.short_name) || Organization.visible.pluck(:short_name).include?(self.short_name)
    end
  end

  def integrated_date
    warn '[DEPRECATION] `integrated_date` is deprecated.  Please use `last_integrated_date` instead.'
    last_integrated_date
  end

  def full_name_short_name
    "#{full_name}(#{short_name})"
  end

  def self.cache_table_exists?(table_name)
    Rails.cache.fetch([Apartment::Tenant.current, 'table_name', table_name]) do
      ActiveRecord::Base.connection.table_exists? table_name
    end
  end

  def self.cache_mapping_ngo_names
    Rails.cache.fetch([Apartment::Tenant.current, 'cache_mapping_ngo_names', Organization.only_deleted.count]) do
      Organization.oscar.map { |org| { org.short_name => org.full_name } }
    end
  end

  def self.full_name_from_short_name(short_name)
    (cache_mapping_ngo_names.find { |name| name.keys[0] == short_name } || {})[short_name]
  end

  def self.cache_visible_ngos
    Rails.cache.fetch([Apartment::Tenant.current, 'Organization', 'visible', Organization.only_deleted.count]) do
      Organization.visible.order(:created_at).to_a
    end
  end

  def self.cached_organization_short_names(short_names)
    Rails.cache.fetch([Apartment::Tenant.current, Organization.only_deleted.count, 'Organization', 'cached_organization_short_names', *short_names.sort]) {
      where('organizations.short_name IN (?)', short_names).pluck(:full_name)
    }
  end

  private

  def upsert_referral_source_category
    org_full_name = self.full_name
    rs_category_name = self.referral_source_category_name

    Organization.all.pluck(:short_name).each do |org_short_name|
      Apartment::Tenant.switch(org_short_name) do
        referral_source = ReferralSource.find_or_create_by(name: "#{org_full_name} - OSCaR Referral")
        rs_category = ReferralSource.find_by(name_en: rs_category_name)
        referral_source.update_attributes(ancestry: "#{rs_category.id}") if rs_category
      end
    end
  end

  def delete_referral_source_category
    org_full_name = self.full_name
    Organization.all.pluck(:short_name).each do |org_short_name|
      Apartment::Tenant.switch! org_short_name
      referral_source = ReferralSource.find_by(name: "#{org_full_name} - OSCaR Referral")
      referral_source.destroy if referral_source
    end
  end

  def flush_cache
    Rails.cache.delete(['current_organization', short_name])
    Rails.cache.delete([Apartment::Tenant.current, 'cache_mapping_ngo_names', Organization.only_deleted.count])
    Rails.cache.delete([Apartment::Tenant.current, 'Organization', 'visible', Organization.only_deleted.count])
    cached_organization_short_names_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_organization_short_names/].blank? }
    cached_organization_short_names_keys.each { |key| Rails.cache.delete(key) }
  end
end
