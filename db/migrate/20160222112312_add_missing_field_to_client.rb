class AddMissingFieldToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :reason_for_referral, :text, default: ''
    add_column :clients, :is_receiving_additional_benefits, :boolean, default: false
    add_column :clients, :background, :text, default: ''
  end
end
