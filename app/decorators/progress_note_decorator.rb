class ProgressNoteDecorator < Draper::Decorator
  delegate_all

  def progress_note_type
    model.progress_note_type.note_type if model.progress_note_type
  end

  def material
    model.material.status if model.material
  end

  def location
    model.location.name if model.location
  end

  def date
    model.date.strftime('%d %B, %Y')
  end
end