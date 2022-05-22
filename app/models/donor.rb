class Donor < ActiveRecord::Base
  has_many :sponsors, dependent: :restrict_with_error
  has_many :clients, through: :sponsors
  has_many :donor_organizations, dependent: :destroy
  has_many :organizations, through: :donor_organizations


  has_paper_trail

  scope :has_clients, -> { joins(:clients).uniq }

  validates :name, presence: true, uniqueness: { case_sensitive: false },               if: 'code.blank?'
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :code }, if: 'code.present?'
  validates :code, uniqueness: { case_sensitive: false }, if: 'code.present?'

  after_commit :flush_cache

  def self.cached_find(id)
    Rails.cache.fetch([Apartment::Tenant.current, 'Donor', id]) { find(id) }
  end

  def self.cached_order_name
    Rails.cache.fetch([Apartment::Tenant.current, 'Donor', 'cached_order_name']) { order(:name).to_a }
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'Donor', id])
    Rails.cache.delete([Apartment::Tenant.current, 'Donor', 'cached_order_name'])
  end
end
