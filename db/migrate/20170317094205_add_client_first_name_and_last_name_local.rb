class AddClientFirstNameAndLastNameLocal < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :local_first_name, :string, default: ''
    add_column :clients, :local_last_name, :string, default: ''
  end
end
