class AddCallIdToClient < ActiveRecord::Migration
  def change
    add_reference :clients, :call, index: true, foreign_key: true
  end
end
