class MoveOtherMoreInformationFromClientToCall < ActiveRecord::Migration
  def change
    remove_column :clients, :other_more_information, :string

    add_column :calls, :other_more_information, :string, default: ''
  end
end
