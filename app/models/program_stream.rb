class ProgramStream < ActiveRecord::Base
  FREQUENCIES  = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze

  validates :name, :enrollment, :tracking, :exit_program, presence: true

end
