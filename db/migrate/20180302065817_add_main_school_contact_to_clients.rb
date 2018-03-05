class AddMainSchoolContactToClients < ActiveRecord::Migration
  def change
    add_column :clients, :main_school_contact, :string
  end
end
