class AddUserIdToAdvancedSearch < ActiveRecord::Migration[5.2]
  def change
    add_reference :advanced_searches, :user, index: true, foreign_key: true
  end
end
