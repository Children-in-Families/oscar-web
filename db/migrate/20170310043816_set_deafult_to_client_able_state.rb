class SetDeafultToClientAbleState < ActiveRecord::Migration
  def change
    change_column :clients, :able_state, :string, default: ''

    Client.where(able_state: nil).each do |client|
      client.update_attributes(able_state: '')
    end
  end
end
