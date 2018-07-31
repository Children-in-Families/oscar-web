class Province < ActiveRecord::Base
  has_paper_trail

  has_many :users, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :partners, dependent: :restrict_with_error
  has_many :clients, dependent: :restrict_with_error
  has_many :cases, dependent: :restrict_with_error
  has_many :districts, dependent: :restrict_with_error
  has_many :settings, dependent: :restrict_with_error
  has_many :government_forms, dependent: :restrict_with_error

  scope :has_clients,  -> { joins(:clients).uniq }

  scope :birth_places, -> { joins('RIGHT JOIN clients ON clients.birth_province_id = Provinces.id').uniq }

  scope :country_is, ->(country) { where(country: country).order(:name) }
  scope :official, -> { where.not(name: ['បោយប៉ែត/Poipet', 'Community', 'Other / ផ្សេងៗ', 'នៅ​ខាង​ក្រៅ​កម្ពុជា / Outside Cambodia']) }

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :country }

  def removeable?
    families.count.zero? && partners.count.zero? && users.count.zero? && clients.count.zero? && cases.count.zero?
  end

  def name_kh
    name.split(' / ').first
  end
end
