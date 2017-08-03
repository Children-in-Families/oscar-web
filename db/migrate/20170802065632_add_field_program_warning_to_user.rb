class AddFieldProgramWarningToUser < ActiveRecord::Migration
  def change
    add_column :users, :program_warning, :boolean, default: false
  end
end
