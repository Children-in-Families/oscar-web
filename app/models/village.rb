class Village < ActiveRecord::Base
  has_paper_trail

  belongs_to :commune, touch: true
  has_many :government_forms, dependent: :restrict_with_error
  has_many :clients, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :communities, dependent: :restrict_with_error

  validates :commune, :name_kh, :name_en, presence: true
  validates :code, presence: true, uniqueness: true

  scope :dropdown_list_option, -> { joins(:clients).map { |c| { c.id => c.name } } }

  after_commit :flush_cache

  def code_format
    "#{name_kh} / #{name_en} (#{code})"
  end

  def name
    "#{name_kh} / #{name_en}"
  end

  def self.get_village(village_code)
    village = find_by(code: village_code.rjust(8, '0'))
    if village
      { village_id: village.id, commune_id: village.commune&.id, district_id: village.commune.district&.id, province_id: village.commune.district.province&.id }
    else
      { village_id: nil }
    end
  end

  def self.get_village_name_by_code(village_code)
    result = find_by(code: village_code)
    { cp: result.commune&.district&.province&.name, cd: result.commune&.district&.name, cc: result.commune&.name, cv: result&.name }
  end

  def self.cached_dropdown_list_option
    Rails.cache.fetch([Apartment::Tenant.current, 'Village', 'dropdown_list_option']) { Village.dropdown_list_option }
  end

  def self.cache_village_name_by_client_commune_district_province
    Rails.cache.fetch([Apartment::Tenant.current, 'Village', 'cache_village_name_by_client_commune_district_province']) do
      Village.joins(:clients, commune: [district: :province]).distinct.map { |village| ["#{village.name_kh} / #{village.name_en} (#{village.code})", village.id] }.sort.map { |s| { s[1].to_s => s[0] } }
    end
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'Village', 'dropdown_list_option'])
    Rails.cache.delete([Apartment::Tenant.current, 'villages'])
  end
end
