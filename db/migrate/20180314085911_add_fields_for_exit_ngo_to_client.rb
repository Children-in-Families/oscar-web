class AddFieldsForExitNgoToClient < ActiveRecord::Migration
  def change
    add_column :clients, :exit_reasons, :string, array: true, default: []
    add_column :clients, :exit_circumstance, :string, default: ''
    add_column :clients, :other_info_of_exit, :string, default: ''
  end
end
