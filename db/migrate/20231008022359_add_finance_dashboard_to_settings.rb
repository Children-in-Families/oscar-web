class AddFinanceDashboardToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :finance_dashboard, :boolean, default: false, null: false
  end
end
