class AddFieldProgramWarningToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :program_warning, :boolean, default: false
  end
end
