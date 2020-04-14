class RemoveVScore < ActiveRecord::Migration
  def change
    remove_column :clients, :v_score
  end
end
