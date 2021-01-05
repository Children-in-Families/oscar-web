class AddCurrentFieldToCase < ActiveRecord::Migration[5.2]
  def change
    add_column :cases, :current, :boolean, default: true
  end
end
