class District < ActiveRecord::Base
  has_paper_trail

  belongs_to :province

  has_many :clients, dependent: :restrict_with_error
  has_many :families, dependent: :restrict_with_error
  has_many :subdistricts, dependent: :destroy
  has_many :communes, dependent: :restrict_with_error
  has_many :government_forms, dependent: :restrict_with_error
  has_many :settings, dependent: :restrict_with_error

  validates :province, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:province_id] }

  scope :dropdown_list_option, -> { joins(:clients).pluck(:name, :id).uniq.sort.map{|s| { s[1].to_s => s[0] } } }

  def name_kh
    name.split(' / ').first
  end
end
