class AddCurrentFieldToCase < ActiveRecord::Migration
  def change
    add_column :cases, :current, :boolean, default: true
  end
end
