class ProgramStream < ActiveRecord::Base
  has_many   :domain_program_streams
  has_many   :domains, through: :domain_program_streams

  validates :name, :rules, :enrollment, :tracking, :exit_program, presence: true

  enum frequencies: { day: 'Daily', week: 'Weekly', month: 'Monthly', year: 'Yearly' }

end
