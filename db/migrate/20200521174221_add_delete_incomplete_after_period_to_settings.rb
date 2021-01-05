class AddDeleteIncompleteAfterPeriodToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :never_delete_incomplete_assessment, :boolean, null: false, default: false
    add_column :settings, :delete_incomplete_after_period_value, :integer, default: 7
    add_column :settings, :delete_incomplete_after_period_unit, :string, default: 'days'
  end
end
