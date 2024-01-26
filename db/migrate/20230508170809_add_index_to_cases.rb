class AddIndexToCases < ActiveRecord::Migration
  def change
    add_index :cases, :case_type
    add_index :cases, :exited
  end
end
