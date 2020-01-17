class AddCallerFieldsToReferee < ActiveRecord::Migration
  def change
    add_column :referees, :answered_call, :boolean
    add_column :referees, :called_before, :boolean
    add_column :referees, :adult, :boolean
    add_column :referees, :requested_update, :boolean, default: false
  end
end
