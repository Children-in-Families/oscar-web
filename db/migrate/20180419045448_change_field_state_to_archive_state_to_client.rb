class ChangeFieldStateToArchiveStateToClient < ActiveRecord::Migration
  def change
    rename_column :clients, :state, :archive_state
  end
end
