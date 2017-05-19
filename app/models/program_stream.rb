class ProgramStream < ActiveRecord::Base
  FREQUENCIES  = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze

  validates :name, :rules, :enrollment, :tracking, :exit_program, presence: true

end
