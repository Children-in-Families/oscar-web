class District < ActiveRecord::Base
  include AddressConcern

  has_paper_trail

  belongs_to :province, touch: true

  has_many :clients, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :subdistricts, dependent: :destroy
  has_many :communes, dependent: :restrict_with_error
  has_many :government_forms, dependent: :restrict_with_error
  has_many :settings, dependent: :restrict_with_error

  validates :province, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:province_id] }

  after_commit :flush_cache

  def name_kh
    name.split(' / ').first
  end

  def self.get_district(district_code)
    district = find_by(code: district_code)
    if district
      { village_id: nil, commune_id: nil, district_id: district.id, province_id: district.province&.id }
    else
      { district_id: nil }
    end
  end

  def self.get_district_name_by_code(district_code)
    result = find_by(code: district_code)
    { cp: result.province&.name, cd: result&.name }
  end

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, 'District', id]) { find(id) }
  end

  def cached_communes
    Rails.cache.fetch([Apartment::Tenant.current, 'District', id, 'cached_communes']) { communes.order(:code).to_a }
  end

  def cached_subdistricts
    Rails.cache.fetch([Apartment::Tenant.current, 'District', id, 'cached_subdistricts']) { subdistricts.order(:name).to_a }
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'District', id])
    Rails.cache.delete([Apartment::Tenant.current, 'District', id, 'cached_communes'])
    Rails.cache.delete([Apartment::Tenant.current, 'District', id, 'cached_subdistricts'])
    Rails.cache.delete([Apartment::Tenant.current, "District", 'dropdown_list_option'])
  end
end
