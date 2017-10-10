class AddUserIdToAdvancedSearch < ActiveRecord::Migration
  def change
    add_reference :advanced_searches, :user, index: true, foreign_key: true
  end
end
