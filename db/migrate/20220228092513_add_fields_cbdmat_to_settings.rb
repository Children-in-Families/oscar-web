class AddFieldsCbdmatToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :cbdmat_one_off, :boolean, default: false
    add_column :settings, :cbdmat_ongoing, :boolean, default: false
  end
end
