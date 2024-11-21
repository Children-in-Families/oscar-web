class EnterNgo < ActiveRecord::Base
  include ReferralStatusConcern

  has_paper_trail
  acts_as_paranoid double_tap_destroys_fully: true

  belongs_to :client, with_deleted: true
  belongs_to :acceptable, polymorphic: true, with_deleted: true
  belongs_to :family, class_name: 'Family', foreign_key: 'acceptable_id'

  alias_attribute :new_date, :accepted_date

  has_many :enter_ngo_users, dependent: :destroy
  has_many :users, through: :enter_ngo_users

  scope :most_recents, -> { order(created_at: :desc) }
  scope :attached_with_clients, -> { where.not(client_id: nil) }

  validates :accepted_date, presence: true
  validates :user_ids, presence: true, on: :create, if: Proc.new { |e| (e.client.present? && e.client.exit_ngo?) || (e.acceptable.present? && e.acceptable.exit_ngo?) }

  before_save :set_administrative_info
  after_create :update_entity_status
  after_save :create_enter_ngo_history
  after_save :flash_cache

  def attached_to_family?
    acceptable_type == 'Family'
  end

  def entity
    client.present? ? client : acceptable
  end

  private

  def update_entity_status
    entity.status = 'Accepted'

    if user_ids.any?
      if client.present?
        entity.user_ids = self.user_ids
      elsif acceptable.present?
        # note the relation between users and acceptable obj
        entity.case_worker_ids = self.user_ids
      end
    end

    entity.received_by_id = received_by_id
    entity.followed_up_by_id = followed_up_by_id
    entity.initial_referral_date = initial_referral_date
    entity.follow_up_date = follow_up_date

    entity.save(validate: false)
  end

  def set_administrative_info
    return unless entity.referred?

    self.received_by_id = entity.received_by_id
    self.followed_up_by_id = entity.followed_up_by_id
    self.initial_referral_date = entity.initial_referral_date
    self.follow_up_date = entity.follow_up_date
  end

  def create_enter_ngo_history
    EnterNgoHistory.initial(self) if ENV['HISTORY_DATABASE_HOST'].present?
  end

  def flash_cache
    Rails.cache.delete(['dashboard', "#{Apartment::Tenant.current}_client_errors"]) if accepted_date_changed?
  end
end
