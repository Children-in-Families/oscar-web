class RemoveDefaultClientFields < ActiveRecord::Migration
  def change
    change_column_default :clients, :has_been_in_orphanage, nil
    change_column_default :clients, :has_been_in_government_care, nil
  end
end
