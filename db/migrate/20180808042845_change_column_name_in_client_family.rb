class ChangeColumnNameInClientFamily < ActiveRecord::Migration
  def up
    rename_column :clients, :commune, :old_commune
    rename_column :clients, :village, :old_village
    rename_column :families, :commune, :old_commune
    rename_column :families, :village, :old_village
    rename_column :settings, :org_commune, :old_commune
  end

  def down
    rename_column :clients, :old_commune, :commune
    rename_column :clients, :old_village, :village
    rename_column :families, :old_commune, :commune
    rename_column :families, :old_village, :village
    rename_column :settings, :old_commune, :org_commune
  end
end
