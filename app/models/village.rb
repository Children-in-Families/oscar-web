class Village < ActiveRecord::Base
  has_paper_trail

  belongs_to :commune
  has_many :government_forms, dependent: :restrict_with_error

  validates :commune, :name_kh, :name_en, presence: true
  validates :code, presence: true, uniqueness: true

  def code_format
    "#{name_kh} / #{name_en} (#{code})"
  end
end
