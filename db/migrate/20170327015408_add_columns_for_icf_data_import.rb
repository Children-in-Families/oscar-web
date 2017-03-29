class AddColumnsForIcfDataImport < ActiveRecord::Migration
  def change
    add_column :clients, :kid_id, :string, default: ''
    add_column :donors,  :code,   :string, default: ''
    add_column :families, :case_history, :string, default: ''
  end
end
