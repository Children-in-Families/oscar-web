class AddNotAPhoneCallToCall < ActiveRecord::Migration[5.2]
  def change
    add_column :calls, :not_a_phone_call, :boolean, default: false
  end
end
