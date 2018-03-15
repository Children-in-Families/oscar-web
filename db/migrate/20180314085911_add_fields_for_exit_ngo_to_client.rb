class AddFieldsForExitNgoToClient < ActiveRecord::Migration
  def change
    add_column :clients, :exit_reason, :string, array: true, default: []
    add_column :clients, :exit_curcumstance, :string, default: ''
    add_column :clients, :other_info, :string, default: ''
  end
end
