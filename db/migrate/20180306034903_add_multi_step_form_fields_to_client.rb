class AddMultiStepFormFieldsToClient < ActiveRecord::Migration
  def change
    add_column :clients, :name_of_referee, :string, default: ''
    add_column :clients, :referee_phone_number, :string, default: ''
    add_column :clients, :primary_carer_name, :string, default: ''
    add_column :clients, :primary_carer_phone_number, :string, default: ''
    add_column :clients, :main_school_contact, :string, default: ''
    add_column :clients, :rated_for_id_poor, :boolean, default: false
    add_column :clients, :custom_id_number1, :string, default: ''
    add_column :clients, :custom_id_number2, :string, default: ''
  end
end
