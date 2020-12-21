class AddFieldAcceptedDateToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :accepted_date, :date
  end
end
