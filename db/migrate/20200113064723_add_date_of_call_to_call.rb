class AddDateOfCallToCall < ActiveRecord::Migration[5.2]
  def change
    add_column :calls, :date_of_call, :date
  end
end
