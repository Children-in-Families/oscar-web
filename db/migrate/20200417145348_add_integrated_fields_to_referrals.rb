class AddIntegratedFieldsToReferrals < ActiveRecord::Migration[5.2]
  def change
    add_column :referrals, :external_id, :string if !column_exists? :referrals, :external_id
    add_index :referrals, :external_id if !index_exists? :referrals, :external_id
    add_column :referrals, :external_id_display, :string if !column_exists? :referrals, :external_id_display
    add_column :referrals, :mosvy_number, :string if !column_exists? :referrals, :mosvy_number
    add_index :referrals, :mosvy_number if !index_exists? :referrals, :mosvy_number
    add_column :referrals, :external_case_worker_name, :string if !column_exists? :referrals, :external_case_worker_name
    add_column :referrals, :external_case_worker_id, :string if !column_exists? :referrals, :external_case_worker_id
    add_column :referrals, :services, :string if !column_exists? :referrals, :services
  end

  def down
    remove_column :referrals, :external_id, :string if column_exists? :referrals, :external_id
    remove_index :referrals, :external_id if index_exists? :referrals, :external_id
    remove_column :referrals, :external_id_display, :string if column_exists? :referrals, :external_id_display
    remove_column :referrals, :mosvy_number, :string if column_exists? :referrals, :mosvy_number
    remove_index :referrals, :mosvy_number if index_exists? :referrals, :mosvy_number
    remove_column :referrals, :external_case_worker_name, :string if column_exists? :referrals, :external_case_worker_name
    remove_column :referrals, :external_case_worker_id, :string if column_exists? :referrals, :external_case_worker_id
    remove_column :referrals, :services, :string if column_exists? :referrals, :services
  end
end
