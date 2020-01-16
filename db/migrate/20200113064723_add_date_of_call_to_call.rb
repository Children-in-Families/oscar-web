class AddDateOfCallToCall < ActiveRecord::Migration
  def change
    add_column :calls, :date_of_call, :date
  end
end
