class Donor < ActiveRecord::Base
  has_many :clients, dependent: :restrict_with_error

  has_paper_trail

  scope :has_clients, -> { joins(:clients).uniq }

  validates :name, presence: true, uniqueness: { case_sensitive: false },               if: 'code.blank?'
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :code }, if: 'code.present?'
  validates :code, uniqueness: { case_sensitive: false }, if: 'code.present?'
end
