class AddSameAsClientToCarer < ActiveRecord::Migration
  def change
    add_column :carers, :same_as_client, :boolean, default: false
  end
end
