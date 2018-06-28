class ChangeDefaultColumnClients < ActiveRecord::Migration
  def up
    change_column_default :clients, :gender, ''
  end

  def down
  end
end
