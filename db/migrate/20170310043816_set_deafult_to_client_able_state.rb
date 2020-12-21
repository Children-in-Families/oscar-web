class SetDeafultToClientAbleState < ActiveRecord::Migration[5.2]
  def up
    change_column_default :clients, :able_state, ''

    Client.where(able_state: nil).each do |client|
      client.update_attributes(able_state: '')
    end
  end

  def down
    change_column_default :clients, :able_state, nil
  end
end
