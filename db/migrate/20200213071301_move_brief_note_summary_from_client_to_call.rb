class MoveBriefNoteSummaryFromClientToCall < ActiveRecord::Migration
  def change
    remove_column :clients, :brief_note_summary, :string

    add_column :calls, :brief_note_summary, :string, default: ''
  end
end
