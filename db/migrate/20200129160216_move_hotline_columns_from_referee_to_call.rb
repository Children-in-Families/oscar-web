class MoveHotlineColumnsFromRefereeToCall < ActiveRecord::Migration[5.2]
  def change
    remove_column :referees, :answered_call, :boolean
    remove_column :referees, :called_before, :boolean
    remove_column :referees, :requested_update, :boolean

    add_column :calls, :answered_call, :boolean
    add_column :calls, :called_before, :boolean
    add_column :calls, :requested_update, :boolean, default: false
  end
end
