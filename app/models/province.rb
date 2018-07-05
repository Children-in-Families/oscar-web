class Province < ActiveRecord::Base
  has_many :users, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :partners, dependent: :restrict_with_error
  has_many :clients, dependent: :restrict_with_error
  has_many :cases, dependent: :restrict_with_error
  has_many :districts, dependent: :restrict_with_error
  has_many :settings, dependent: :restrict_with_error

  has_paper_trail

  scope :has_clients,  -> { joins(:clients).uniq }

  scope :birth_places, -> { joins('RIGHT JOIN clients ON clients.birth_province_id = Provinces.id').uniq }

  scope :country_is, ->(country) { where(country: country).order(:name) }

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :country }

  def removeable?
    families.count.zero? && partners.count.zero? && users.count.zero? && clients.count.zero? && cases.count.zero?
  end
end
