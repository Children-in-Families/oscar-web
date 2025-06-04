class ReferralHistory < ActiveRecord::Base
  belongs_to :client, with_deleted: true
  belongs_to :followed_up_by, class_name: 'User', foreign_key: 'followed_up_by_id', with_deleted: true
  belongs_to :received_by, class_name: 'User', foreign_key: 'received_by_id', with_deleted: true

  def self.max_count
    group(:client_id).count.values.max || 0
  end

  def users
    User.where(id: user_ids.compact)
  end
end
