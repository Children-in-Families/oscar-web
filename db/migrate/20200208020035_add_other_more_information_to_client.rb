class AddOtherMoreInformationToClient < ActiveRecord::Migration
  def change
    add_column :clients, :other_more_information, :string, default: ''
  end
end
