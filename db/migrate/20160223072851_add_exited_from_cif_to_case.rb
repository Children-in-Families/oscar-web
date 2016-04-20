class AddExitedFromCifToCase < ActiveRecord::Migration
  def change
    add_column :cases, :exited_from_cif, :boolean, default: false
  end
end
