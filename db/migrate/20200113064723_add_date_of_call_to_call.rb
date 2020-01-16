class AddDateOfCallToCall < ActiveRecord::Migration
  def change
    # remove_column :calls, :date_of_call, :datetime
    add_column :calls, :date_of_call, :date
  end
end
