class Donor < ApplicationRecord
  has_many :sponsors, dependent: :restrict_with_error
  has_many :clients, through: :sponsors
  has_many :donor_organizations, dependent: :destroy
  has_many :organizations, through: :donor_organizations


  has_paper_trail

  scope :has_clients, -> { joins(:clients).uniq }

  validates :name, presence: true, uniqueness: { case_sensitive: false },               if: -> { code.blank? }
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :code }, if: -> { code.present? }
  validates :code, uniqueness: { case_sensitive: false }, if: -> { code.present? }
end
