class CaseNoteAttachment
  include Sidekiq::Worker

  def perform(case_note_id, short_name)
    Organization.switch_to short_name

    case_note = CaseNote.find_by(id: case_note_id)
    return if case_note.blank?
    
    attachments = case_note.case_note_domain_groups.map(&:attachments).flatten
    case_note.attachments = attachments.map{ |attachment| Pathname.new(attachment.path).open }
    case_note.save(validate: false)
  rescue => e
    pp e.message
  end
end
