class ProgramStreamPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :program_stream

  scope :order_by_program_name, -> { joins(:program_stream).order('lower(program_streams.name)') }
end
