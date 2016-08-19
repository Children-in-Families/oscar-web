class Survey < ActiveRecord::Base
  belongs_to :client
  
  validates :listening_score, :problem_solving_score,
            :getting_in_touch_score, :trust_score, :difficulty_help_score,
            :support_score, :family_need_score, :care_score,
            presence: true

  before_save :set_user_id

  def set_user_id
    self.user_id = client.user_id
  end
end
