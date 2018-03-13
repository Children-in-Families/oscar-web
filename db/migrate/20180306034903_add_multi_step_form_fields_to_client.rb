class AddMultiStepFormFieldsToClient < ActiveRecord::Migration
  def change
    add_column :clients, :name_of_referee, :string, default: ''
    add_column :clients, :main_school_contact, :string, default: ''
    add_column :clients, :rated_for_id_poor, :string, default: ''
    add_column :clients, :what3words, :string, default: ''
  end
end
