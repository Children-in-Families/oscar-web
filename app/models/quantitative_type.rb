class QuantitativeType < ActiveRecord::Base
  VISIBLE_ON = %w(client family community).freeze
  serialize :visible_on, Array

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate  :validate_visible_on

  has_many :quantitative_cases
  has_many :quantitative_type_permissions, dependent: :destroy
  has_many :users, through: :quantitative_type_permissions

  has_paper_trail

  default_scope { order(name: :asc) }

  accepts_nested_attributes_for :quantitative_cases, reject_if: :all_blank, allow_destroy: true

  scope :name_like, ->(name) { where('quantitative_types.name iLIKE ?', "%#{name}%") }

  after_create :build_permission

  private

  def validate_visible_on
    self.visible_on = visible_on.select(&:present?)

    if visible_on.blank?
      errors.add(:visible_on, :blank)
    elsif visible_on.count > 3 || visible_on.any?{ |visible| VISIBLE_ON.exclude?(visible) }
      errors.add(:visible_on, :invalid)
    end
  end

  def build_permission
    User.non_strategic_overviewers.each do |user|
      self.quantitative_type_permissions.find_or_create_by(user_id: user.id)
    end
  end
end
