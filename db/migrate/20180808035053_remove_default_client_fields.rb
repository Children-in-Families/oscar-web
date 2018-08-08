class RemoveDefaultClientFields < ActiveRecord::Migration
  def up
    change_column_default :clients, :has_been_in_orphanage, nil
    change_column_default :clients, :has_been_in_government_care, nil
  end

  def down
    change_column_default :clients, :has_been_in_orphanage, false
    change_column_default :clients, :has_been_in_government_care, false
  end
end
