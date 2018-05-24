class SharedClient < ActiveRecord::Base
  has_paper_trail

  belongs_to :birth_province, class_name: 'Province', foreign_key: :birth_province_id

  validates :slug, presence: true, uniqueness: { case_sensitive: false }
end
