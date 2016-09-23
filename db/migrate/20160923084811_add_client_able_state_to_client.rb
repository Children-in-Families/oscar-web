class AddClientAbleStateToClient < ActiveRecord::Migration
  def change
    add_column :clients, :able_state, :string
  end
end
