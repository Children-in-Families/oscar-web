class AddFieldCarePlanDateToCarePlans < ActiveRecord::Migration
  def change
    add_column :care_plans, :care_plan_date, :date
    add_index :care_plans, :care_plan_date
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE care_plans SET care_plan_date = created_at;
        SQL
      end
    end
  end
end
