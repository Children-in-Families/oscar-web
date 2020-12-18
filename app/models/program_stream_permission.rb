class ProgramStreamPermission < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, with_deleted: true
  belongs_to :program_stream, with_deleted: true

  scope :order_by_program_name, -> { joins(:program_stream).order('lower(program_streams.name)') }
end
