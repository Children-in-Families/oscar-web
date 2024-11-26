class Service < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :global_service, class_name: 'GlobalService', foreign_key: 'uuid'
  belongs_to :parent, class_name: 'Service'
  has_many :children, class_name: 'Service', foreign_key: 'parent_id', dependent: :destroy

  has_many :program_stream_services, dependent: :destroy
  has_many :program_streams, through: :program_stream_services
  has_and_belongs_to_many :referrals

  validates :name, presence: true

  after_commit :flush_cache

  scope :only_parents, -> { where(parent_id: nil) }
  scope :only_children, -> { where.not(parent_id: nil) }
  scope :names, -> { only_children.pluck(:name) }

  def self.cache_only_child_services
    Rails.cache.fetch([Apartment::Tenant.current, 'Service', 'cache_only_child_services']) do
      self.only_children.pluck(:name, :id).uniq.sort.map { |s| { s[1].to_s => s[0] } }
    end
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'Service', 'cache_only_child_services'])
    program_streams.each do |program_stream|
      Rails.cache.delete([Apartment::Tenant.current, 'services', 'ProgramStream', program_stream.id])
    end
  end
end
