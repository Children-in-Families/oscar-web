class AddUserToFamily < ActiveRecord::Migration
  def change
    add_reference :families, :user, index: true, foreign_key: true
  end
end
