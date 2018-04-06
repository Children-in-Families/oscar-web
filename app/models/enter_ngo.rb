class EnterNgo < ActiveRecord::Base
  belongs_to :client

  has_many :enter_ngo_users, dependent: :destroy
  has_many :users, through: :enter_ngo_users

  validates :accepted_date, presence: true
  validates :user_ids, presence: true, on: :create, if: Proc.new { |e| e.client.exit_ngo? }

  after_create :set_client_status

  private


  def set_client_status
    if user_ids.blank?
      client.update(status: 'Accepted')
    else
      client.update(status: 'Accepted', user_ids: self.user_ids)
    end
  end

end
