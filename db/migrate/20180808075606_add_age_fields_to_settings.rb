class AddAgeFieldsToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :age, :integer, default: 18
  end
end
