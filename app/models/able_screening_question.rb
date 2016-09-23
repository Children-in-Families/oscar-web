class AbleScreeningQuestion < ActiveRecord::Base

  MODES  = %w(yes_no free_text).freeze
  GROUPS = %w(social_skill cognitive_skill).freeze

  belongs_to :stage
  has_many :answers, dependent: :destroy
  has_many :clients, through: :answers
  has_many :attachments

  accepts_nested_attributes_for :attachments

  scope :non_stage, -> { where(stage: nil) }

  validates :question, :mode, presence: true
  validates :mode, inclusion: { in: MODES }

  def has_stage?
    !stage.non_stage
  end

  def has_group?
    group.present?
  end

  def free_text?
    mode == MODES[1]
  end

  def yes_no?
    mode == MODES[0]
  end

  def self.has_alert_manager?(client)
    where(alert_manager: true).joins(:clients)
                                .where('clients.id = ?', client.id).any?
  end
end
