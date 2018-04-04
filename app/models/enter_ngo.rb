class EnterNgo < ActiveRecord::Base
  belongs_to :client, :inverse_of => :enter_ngos

  has_many :case_worker_clients, dependent: :destroy
  has_many :users, through: :case_worker_clients

  validates :accepted_date, presence: true

  after_create do
    client.update_attribute(:status, 'Accepted')
  end
end
