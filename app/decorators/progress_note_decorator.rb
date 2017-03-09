class ProgressNoteDecorator < Draper::Decorator
  delegate_all

  def client
    model.client.name
  end

  def client_slug_id
    model.client.slug
  end

  def user
    model.user.name
  end

  def progress_note_type
    model.progress_note_type.note_type if model.progress_note_type
  end

  def material
    model.material.status if model.material
  end

  def location
    model.location.name if model.location
  end
end
