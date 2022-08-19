class RiskAssessment < ActiveRecord::Base
  belongs_to :client
  has_many :tasks, as: :taskable, dependent: :destroy

  accepts_nested_attributes_for :tasks, reject_if:  proc { |attributes| attributes['name'].blank? && attributes['expected_date'].blank? }, allow_destroy: true

  after_commit :save_client_tasks

  private

  def save_client_tasks
    tasks.update_all(client_id: client_id)
  end

end
