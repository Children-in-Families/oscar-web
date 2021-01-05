class DomainProgramStream < ApplicationRecord
  acts_as_paranoid

  belongs_to :program_stream
  belongs_to :domain
end
