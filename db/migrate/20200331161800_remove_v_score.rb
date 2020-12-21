class RemoveVScore < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :v_score
  end
end
