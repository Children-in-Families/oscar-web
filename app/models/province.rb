class Province < ActiveRecord::Base
  include AddressConcern

  has_paper_trail

  has_many :users, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :partners, dependent: :restrict_with_error
  has_many :clients, dependent: :restrict_with_error
  has_many :cases, dependent: :restrict_with_error
  has_many :districts, dependent: :restrict_with_error
  has_many :cities, dependent: :restrict_with_error
  has_many :settings, dependent: :restrict_with_error
  has_many :government_forms, dependent: :restrict_with_error

  scope :has_clients, -> { joins(:clients).uniq }

  scope :birth_places, -> { joins('RIGHT JOIN clients ON clients.birth_province_id = Provinces.id').uniq }

  scope :country_is, -> (country) { where(country: country).order(:name) }
  scope :official, -> { where.not(name: ['បោយប៉ែត/Poipet', 'Community', 'Other / ផ្សេងៗ', 'នៅ​ខាង​ក្រៅ​កម្ពុជា / Outside Cambodia']) }

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :country }

  after_commit :flush_cache

  def self.cache_by_country(country)
    Rails.cache.fetch([Apartment::Tenant.current, self.name, 'cache_by_country']) do
      order(:name).to_a
    end.select { |province| province.country == country }
  end

  def removeable?
    families.count.zero? && partners.count.zero? && users.count.zero? && clients.count.zero? && cases.count.zero?
  end

  def name_kh
    name.split(' / ').first
  end

  def self.map_name_by_code(code)
    result = find_by_code(code)
    { cp: result&.name }
  end

  def self.address_by_code(code)
    result = find_by_code(code)
    if result
      { village_id: nil, commune_id: nil, district_id: nil, province_id: result&.id }
    else
      { province_id: nil }
    end
  end

  def self.find_name_by_code(code)
    district = District.where('code LIKE ?', "#{code}%").first
    district&.province&.name
  end

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, 'Province', id]) { find(id) }
  end

  def self.cached_order_name
    Rails.cache.fetch([Apartment::Tenant.current, 'Province', 'cached_order_name']) { order(:name).to_a }
  end

  def cached_districts
    Rails.cache.fetch([Apartment::Tenant.current, 'Province', id, 'cached_districts']) { districts.order(:name).to_a }
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'Province', id])
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, 'cache_by_country'])
    Rails.cache.delete([Apartment::Tenant.current, 'Province', 'cached_order_name']) if name_changed?
    Rails.cache.delete([Apartment::Tenant.current, 'Province', id, 'cached_districts'])
    Rails.cache.delete([Apartment::Tenant.current, 'Province', 'dropdown_list_option'])
  end
end
