class ReferralHistory < ActiveRecord::Base
  belongs_to :client, with_deleted: true
  belongs_to :followed_up_by, class_name: 'User', foreign_key: 'followed_up_by_id', with_deleted: true
  belongs_to :received_by, class_name: 'User', foreign_key: 'received_by_id', with_deleted: true

  validates :client_id, presence: true
  validates :referral_date, presence: true

  def self.max_count
    group(:client_id).count.values.max || 0
  end

  def users
    User.where(id: user_ids.compact)
  end

  def initial_referral_date
    referral_date || created_at
  end
end
