class ProgramStreamService < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :program_stream
  belongs_to :service
end
