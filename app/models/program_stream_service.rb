class ProgramStreamService < ApplicationRecord
  acts_as_paranoid

  belongs_to :program_stream
  belongs_to :service

  default_scope { with_deleted }
end
