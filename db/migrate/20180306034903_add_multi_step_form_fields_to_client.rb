class AddMultiStepFormFieldsToClient < ActiveRecord::Migration
  def change
    add_column :clients, :name_of_referee, :string, default: ''
    add_column :clients, :main_school_contact, :string, default: ''
    add_column :clients, :rated_for_id_poor, :boolean, default: false
  end
end
