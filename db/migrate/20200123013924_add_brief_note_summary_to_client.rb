class AddBriefNoteSummaryToClient < ActiveRecord::Migration[5.2]
  def change
    # find this field in hotline form
    add_column :clients, :brief_note_summary, :string, default: ''
  end
end
