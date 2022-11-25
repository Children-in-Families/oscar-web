class AddExitedFromCifToCase < ActiveRecord::Migration[5.2]
  def change
    add_column :cases, :exited_from_cif, :boolean, default: false
  end
end
