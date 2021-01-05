class RenameClientNameFields < ActiveRecord::Migration[5.2]
  def change
    rename_column :clients, :first_name,       :given_name
    rename_column :clients, :last_name,        :family_name
    rename_column :clients, :local_first_name, :local_given_name
    rename_column :clients, :local_last_name,  :local_family_name
  end
end
