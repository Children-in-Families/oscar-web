class AddReferenceOrignaztionIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :organization, index: true, foreign_key: true
  end
end
