class Village < ActiveRecord::Base
  has_paper_trail

  belongs_to :commune
  has_many :government_forms, dependent: :restrict_with_error
  has_many :clients, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error

  validates :commune, :name_kh, :name_en, presence: true
  validates :code, presence: true, uniqueness: true

  scope :dropdown_list_option, -> { all.map{|c| { c.id => c.name } } }

  def code_format
    "#{name_kh} / #{name_en} (#{code})"
  end

  def name
    "#{name_kh} / #{name_en}"
  end

  def self.get_village(village_code)
    village = find_by(code: village_code)
    if village
      { village_id: village.id, commune_id: village.commune&.id, district_id: village.commune.district&.id, province_id: village.commune.district.province&.id }
    else
      { village_id: nil }
    end
  end

  def self.get_village_name_by_code(village_code)
    result = find_by(code: village_code)
    { cp: result.commune&.district&.province&.name, cd: result.commune&.district&.name, cc: result.commune&.name, cv: result&.name }
  end
end
