class Commune < ActiveRecord::Base
  include AddressConcern

  attr_accessor :name
  has_paper_trail

  belongs_to :city, touch: true
  belongs_to :district, touch: true
  has_many :villages, dependent: :restrict_with_error
  has_many :government_forms, dependent: :restrict_with_error
  has_many :clients, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :communities, dependent: :restrict_with_error
  has_many :settings, dependent: :restrict_with_error

  validates :district, :name_kh, :name_en, presence: true
  validates :code, presence: true, uniqueness: true

  scope :dropdown_list_option, -> { all.map { |c| { c.id => c.name } } }

  after_commit :flush_cache

  def name
    district_type ? name_en : "#{name_kh} / #{name_en}"
  end

  def code_format
    district_type ? "#{name_en} (#{code})" : "#{name_kh} / #{name_en} (#{code})"
  end

  def self.get_commune(commune_code)
    commune = find_by(code: commune_code.rjust(6, '0'))
    if commune
      { village_id: nil, commune_id: commune.id, district_id: commune.district&.id, province_id: commune.district.province&.id }
    else
      { commune_id: nil }
    end
  end

  def self.get_commune_name_by_code(commune_code)
    result = find_by(code: commune_code)
    { cp: result.district&.province&.name, cd: result.district&.name, cc: result&.name }
  end

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, 'Commune', id]) { find(id) }
  end

  def cached_villages
    Rails.cache.fetch([Apartment::Tenant.current, 'Commune', id, 'cached_villages']) { villages.order(:code).to_a }
  end

  def self.cache_by_client_district_province_and_mapping_names
    Rails.cache.fetch([Apartment::Tenant.current, 'Commune', 'cache_by_client_district_province_and_mapping_names']) do
      Commune.joins(:clients, district: :province).distinct.map { |commune| ["#{commune.name} (#{commune.code})", commune.id] }.sort.map { |s| { s[1].to_s => s[0] } }
    end
  end

  def self.cache_by_client_district_province_and_mapping_names
    Rails.cache.fetch([Apartment::Tenant.current, 'Commune', 'cache_by_client_district_province_and_mapping_names']) do
      Commune.joins(:clients, district: :province).distinct.map { |commune| ["#{commune.name} (#{commune.code})", commune.id] }.sort.map { |s| { s[1].to_s => s[0] } }
    end
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'Commune', id])
    Rails.cache.delete([Apartment::Tenant.current, 'Commune', id, 'cached_villages'])
    Rails.cache.delete([Apartment::Tenant.current, 'Commune', 'dropdown_list_option'])
    Rails.cache.delete([Apartment::Tenant.current, 'Commune', 'cache_by_client_district_province_and_mapping_names']) if name_kh_changed? || name_en_changed?
  end
end
