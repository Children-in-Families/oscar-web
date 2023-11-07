class City < ActiveRecord::Base
  belongs_to :province

  has_many :districts, dependent: :destroy
  has_many :clients, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :referees, dependent: :restrict_with_error
  has_many :carers, dependent: :restrict_with_error
  has_many :communes, dependent: :restrict_with_error
  has_many :settings, dependent: :restrict_with_error

  validates :province, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:province_id] }
end
