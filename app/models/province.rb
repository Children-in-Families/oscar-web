class Province < ActiveRecord::Base
  has_many :users
  has_many :families
  has_many :partners
  has_many :clients
  has_many :cases

  has_paper_trail

  scope :has_clients,  -> { joins(:clients).uniq }

  scope :birth_places, -> { joins('RIGHT JOIN clients ON clients.birth_province_id = Provinces.id').uniq }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def removeable?
    families.count.zero? && partners.count.zero? && users.count.zero? && clients.count.zero? && cases.count.zero?
  end
end
