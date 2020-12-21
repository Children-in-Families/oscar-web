class AddIntegratedFieldsToReferrals < ActiveRecord::Migration[5.2]
  def change
    add_column :referrals, :external_id, :string
    add_index :referrals, :external_id
    add_column :referrals, :external_id_display, :string
    add_column :referrals, :mosvy_number, :string
    add_index :referrals, :mosvy_number
    add_column :referrals, :external_case_worker_name, :string
    add_column :referrals, :external_case_worker_id, :string
    add_column :referrals, :services, :string
  end
end
