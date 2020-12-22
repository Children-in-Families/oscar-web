class AddSameAsClientToCarer < ActiveRecord::Migration[5.2]
  def change
    add_column :carers, :same_as_client, :boolean, default: false
  end
end
