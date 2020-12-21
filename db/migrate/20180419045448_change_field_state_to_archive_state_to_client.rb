class ChangeFieldStateToArchiveStateToClient < ActiveRecord::Migration[5.2]
  def change
    rename_column :clients, :state, :archive_state
  end
end
