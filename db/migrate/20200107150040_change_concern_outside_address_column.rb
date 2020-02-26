class ChangeConcernOutsideAddressColumn < ActiveRecord::Migration
  def up
    change_column :clients, :concern_outside_address, :string, default: ""
  end

  def down
    change_column :clients, :concern_outside_address, :string, default: ""
  end
end
