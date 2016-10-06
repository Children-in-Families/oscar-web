class AbleScreeningQuestion < ActiveRecord::Base

  MODES  = %w(yes_no free_text).freeze

  belongs_to :stage
  belongs_to :question_group
  has_many :answers, dependent: :destroy
  has_many :clients, through: :answers
  has_many :attachments

  accepts_nested_attributes_for :attachments

  scope :non_stage, -> { where(stage: nil) }
  scope :with_stage, -> { where.not(stage: nil) }

  validates :question, :mode, presence: true
  validates :mode, inclusion: { in: MODES }

  delegate :from_age_as_date, :to_age_as_date, :non_stage, to: :stage, allow_nil: true

  def has_image?
    attachments.any?
  end

  def first_image
    attachments.first.image if attachments.any?
  end

  def has_stage?
    stage.present?
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
