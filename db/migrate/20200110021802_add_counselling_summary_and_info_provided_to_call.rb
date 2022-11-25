class AddCounsellingSummaryAndInfoProvidedToCall < ActiveRecord::Migration[5.2]
  def change
    add_column :calls, :phone_counselling_summary, :string, default: ''
    add_column :calls, :information_provided, :string, default: ''
  end
end
