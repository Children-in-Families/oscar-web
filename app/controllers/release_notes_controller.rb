class ReleaseNotesController < AdminController
  def index
    @release_notes = ReleaseNote.order('created_at DESC').published.page(params[:page]).per(1)
    @release_note = @release_notes.first
    current_user.notifications.relase_note.unread.where(notifiable: @release_note).update_all(seen_at: Time.now)
  end
end
