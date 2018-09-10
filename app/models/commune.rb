class Commune < ActiveRecord::Base
  has_paper_trail

  belongs_to :district
  has_many :villages, dependent: :restrict_with_error
  has_many :government_forms, dependent: :restrict_with_error
  has_many :clients, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :settings, dependent: :restrict_with_error

  validates :district, :name_kh, :name_en, presence: true
  validates :code, presence: true, uniqueness: true

  attr_accessor :name

  def name
    "#{name_kh} / #{name_en}"
  end

  def code_format
    "#{name_kh} / #{name_en} (#{code})"
  end
end
