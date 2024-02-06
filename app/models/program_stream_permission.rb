class ProgramStreamPermission < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user, with_deleted: true
  belongs_to :program_stream, with_deleted: true

  scope :order_by_program_name, -> { joins(:program_stream).order('lower(program_streams.name)') }

  after_commit :flash_cache

  private

  def flash_cache
    Rails.cache.delete([Apartment::Tenant.current, 'program_permission_editable', 'ProgramStream', 'User', progrm_stream.id, user.id])
  end
end
