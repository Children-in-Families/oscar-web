class MovePhoneCounsellingSummaryFromCallToClient < ActiveRecord::Migration[5.2]
  def change
    remove_column :calls, :phone_counselling_summary, :string
    add_column :clients, :phone_counselling_summary, :string, default: ''
  end
end
