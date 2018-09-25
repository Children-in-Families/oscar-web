class AddFieldRelationToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :relation, :string, default: ''
  end
end
