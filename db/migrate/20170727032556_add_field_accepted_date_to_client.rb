class AddFieldAcceptedDateToClient < ActiveRecord::Migration
  def change
    add_column :clients, :accepted_date, :date
  end
end
