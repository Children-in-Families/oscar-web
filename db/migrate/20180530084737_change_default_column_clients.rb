class ChangeDefaultColumnClients < ActiveRecord::Migration[5.2]
  def up
    change_column_default :clients, :gender, ''
  end

  def down
  end
end
