class Domain < ActiveRecord::Base
  belongs_to :domain_group, counter_cache: true

  has_many   :assessment_tasks
  has_many   :assessment_domains

  validates :domain_group, presence: true
  validates :identity, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  default_scope { order('domain_group_id ASC, name ASC') }
end
