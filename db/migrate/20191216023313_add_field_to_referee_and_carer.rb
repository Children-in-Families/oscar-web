class AddFieldToRefereeAndCarer < ActiveRecord::Migration
  def change
    add_column :referees, :name, :string, default: ''
    add_column :referees, :phone, :string, default: ''
    add_column :carers, :name, :string, default: ''
    add_column :carers, :phone, :string, default: ''
  end
end
