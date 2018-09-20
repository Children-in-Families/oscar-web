class AddAgeFieldsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :age, :integer, default: 18
  end
end
