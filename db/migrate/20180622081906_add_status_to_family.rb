class AddStatusToFamily < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :status, :string, default: ''
  end
end
